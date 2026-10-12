package controllers

import (
	"context"
	"encoding/json"
	"encoding/xml"
	"fmt"
	"html/template"
	"net"
	"net/http"
	"net/netip"
	"os"
	"path/filepath"
	"strconv"
	"strings"
	"sync"
	"time"
)

type Info struct {
	XMLName    xml.Name `json:"-" xml:"info"`
	IP         string   `json:"ip_addr" xml:"ip_addr"`
	Host       string   `json:"remote_host" xml:"remote_host"`
	UserAgent  string   `json:"user_agent" xml:"user_agent"`
	Port       string   `json:"port" xml:"port"`
	Lang       string   `json:"lang" xml:"lang"`
	Connection string   `json:"connection" xml:"connection"`
	Keepalive  string   `json:"keep_alive" xml:"keep_alive"`
	Encoding   string   `json:"encoding" xml:"encoding"`
	Mime       string   `json:"mime" xml:"mime"`
	Charset    string   `json:"charset" xml:"charset"`
	Via        string   `json:"via" xml:"via"`
	Forwarded  string   `json:"forwarded" xml:"forwarded"`
	Method     string   `json:"method" xml:"method"`
	Referer    string   `json:"referer" xml:"referer"`
	Email      string   `json:"email" xml:"email"`
}

// Examples use the same serializers as the API and are escaped by html/template.
func (i Info) JSONExample() string {
	value, _ := json.Marshal(i)
	return string(value)
}
func (i Info) XMLExample() string {
	value, _ := xml.MarshalIndent(i, "", "  ")
	return string(value)
}

type cachedHost struct {
	host    string
	expires time.Time
}
type Handler struct {
	page   *template.Template
	static http.Handler
	lookup func(context.Context, string) ([]string, error)
	mu     sync.Mutex
	cache  map[string]cachedHost
}

func NewHandler(views, static string) (*Handler, error) {
	page, err := template.ParseFiles(filepath.Join(views, "index.tpl"))
	if err != nil {
		return nil, err
	}
	return &Handler{page: page, static: http.StripPrefix("/static/", http.FileServer(http.Dir(static))), lookup: net.DefaultResolver.LookupAddr, cache: make(map[string]cachedHost)}, nil
}

// Only loopback nginx may supply the server-owned forwarding headers.
// Public backends must never accept these headers from arbitrary peers.
func source(r *http.Request) (string, string) {
	host, port, err := net.SplitHostPort(r.RemoteAddr)
	if err != nil {
		return r.RemoteAddr, ""
	}
	peer, err := netip.ParseAddr(host)
	if err != nil {
		return host, port
	}
	host = peer.Unmap().String()
	if !peer.IsLoopback() {
		return host, port
	}
	forwarded, err := netip.ParseAddr(r.Header.Get("X-Tih-Forwarded-For"))
	if err != nil {
		return host, port
	}
	host = forwarded.Unmap().String()
	// The proxy connection's port is not the client's port. Missing or malformed
	// forwarded ports remain empty rather than panicking or inventing a value.
	port = ""
	if value := r.Header.Get("X-Tih-Forwarded-For-Port"); value != "" {
		if n, err := strconv.Atoi(value); err == nil && n > 0 && n <= 65535 {
			port = strconv.Itoa(n)
		}
	}
	return host, port
}

func (h *Handler) hostname(ctx context.Context, ip string) string {
	if _, err := netip.ParseAddr(ip); err != nil {
		return ""
	}
	h.mu.Lock()
	cached, ok := h.cache[ip]
	h.mu.Unlock()
	if ok && time.Now().Before(cached.expires) {
		return cached.host
	}
	ctx, cancel := context.WithTimeout(ctx, time.Second)
	defer cancel()
	names, err := h.lookup(ctx, ip)
	host := ""
	if err == nil {
		for i := range names {
			names[i] = strings.TrimSuffix(names[i], ".")
		}
		host = strings.Join(names, "\n")
	}
	h.mu.Lock()
	// Bound memory even when many clients have different source addresses.
	if len(h.cache) >= 1024 {
		clear(h.cache)
	}
	h.cache[ip] = cachedHost{host: host, expires: time.Now().Add(5 * time.Minute)}
	h.mu.Unlock()
	return host
}

func (h *Handler) info(r *http.Request, resolve bool) Info {
	ip, port := source(r)
	info := Info{IP: ip, Port: port, UserAgent: r.UserAgent(), Lang: r.Header.Get("Accept-Language"), Connection: r.Header.Get("Connection"), Keepalive: r.Header.Get("Keep-Alive"), Encoding: r.Header.Get("Accept-Encoding"), Mime: r.Header.Get("Accept"), Charset: r.Header.Get("Accept-Charset"), Via: r.Header.Get("Via"), Forwarded: r.Header.Get("X-Forwarded-For"), Method: r.Method, Referer: r.Referer(), Email: "admin@ifconfig.tw"}
	if resolve {
		info.Host = h.hostname(r.Context(), ip)
	}
	return info
}

func known(path string) bool {
	switch path {
	case "/", "/ip", "/host", "/ua", "/port", "/keepalive", "/lang", "/connection", "/encoding", "/via", "/mime", "/charset", "/forwarded", "/all", "/all.xml", "/all.json":
		return true
	}
	return false
}

func (h *Handler) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("X-Content-Type-Options", "nosniff")
	w.Header().Set("Cache-Control", "no-store")
	if strings.HasPrefix(r.URL.Path, "/static/") {
		h.static.ServeHTTP(w, r)
		return
	}
	if !known(r.URL.Path) || (r.URL.Path == "/" && os.Getenv("NOWEB") == "1") {
		http.NotFound(w, r)
		return
	}
	w.Header().Set("Allow", "GET, HEAD, OPTIONS")
	if r.Method == http.MethodOptions {
		w.WriteHeader(http.StatusNoContent)
		return
	}
	if r.Method != http.MethodGet && r.Method != http.MethodHead {
		http.Error(w, "method not allowed", http.StatusMethodNotAllowed)
		return
	}
	plainRoot := r.URL.Path == "/" && strings.Contains(strings.ToLower(r.UserAgent()), "curl")
	resolve := r.URL.Path == "/host" || r.URL.Path == "/all" || r.URL.Path == "/all.json" || r.URL.Path == "/all.xml" || (r.URL.Path == "/" && !plainRoot)
	info := h.info(r, resolve)
	if r.URL.Path == "/all.json" {
		w.Header().Set("Content-Type", "application/json; charset=utf-8")
		var value any = info
		if r.URL.Query().Get("format") == "legacy" {
			value = legacyJSON(info)
		}
		_ = json.NewEncoder(w).Encode(value)
		return
	}
	if r.URL.Path == "/all.xml" {
		w.Header().Set("Content-Type", "application/xml; charset=utf-8")
		var value any = info
		if r.URL.Query().Get("format") == "legacy" {
			value = legacyXML(info)
		}
		_ = xml.NewEncoder(w).Encode(value)
		return
	}
	if r.URL.Path == "/" && !plainRoot {
		w.Header().Set("Content-Type", "text/html; charset=utf-8")
		_ = h.page.Execute(w, info)
		return
	}
	w.Header().Set("Content-Type", "text/plain; charset=utf-8")
	var value string
	switch r.URL.Path {
	case "/", "/ip":
		value = info.IP
	case "/host":
		value = info.Host
	case "/ua":
		value = info.UserAgent
	case "/port":
		value = info.Port
	case "/keepalive":
		value = info.Keepalive
	case "/lang":
		value = info.Lang
	case "/connection":
		value = info.Connection
	case "/encoding":
		value = info.Encoding
	case "/via":
		value = info.Via
	case "/mime":
		value = info.Mime
	case "/charset":
		value = info.Charset
	case "/forwarded":
		value = info.Forwarded
	case "/all":
		fmt.Fprintf(w, "ip_addr: %s\nremote_host: %s\nuser_agent: %s\nport: %s\nlang: %s\nconnection: %s\nkeep_alive: %s\nencoding: %s\nmime: %s\ncharset: %s\nvia: %s\nforwarded: %s\n", info.IP, info.Host, info.UserAgent, info.Port, info.Lang, info.Connection, info.Keepalive, info.Encoding, info.Mime, info.Charset, info.Via, info.Forwarded)
		return
	}
	fmt.Fprintln(w, value)
}

type oldInfo struct {
	XMLName    xml.Name `json:"-" xml:"ifconfig"`
	Email      string
	UserAgent  string
	Host       string
	IP         string
	Port       string
	Method     string
	Encoding   string
	Mime       string
	Connection string
	Via        string
	Charset    string
	Keepalive  string
	Forwarded  string
	Lang       string
	Referer    string
}

func legacyXML(i Info) oldInfo {
	host := i.Host
	if host != "" {
		host += "\n"
	}
	return oldInfo{Email: i.Email, UserAgent: i.UserAgent, Host: host, IP: i.IP, Port: i.Port, Method: i.Method, Encoding: i.Encoding, Mime: i.Mime, Connection: i.Connection, Via: i.Via, Charset: i.Charset, Keepalive: i.Keepalive, Forwarded: i.Forwarded, Lang: i.Lang, Referer: i.Referer}
}
func legacyJSON(i Info) map[string]string {
	old := legacyXML(i)
	result := map[string]string{"Email": old.Email, "UserAgent": old.UserAgent, "Host": old.Host, "IP": old.IP, "Port": old.Port, "Method": old.Method, "Referer": old.Referer}
	for key, value := range map[string]string{"Encoding": old.Encoding, "Mime": old.Mime, "Connection": old.Connection, "Via": old.Via, "Charset": old.Charset, "Keepalive": old.Keepalive, "Forwarded": old.Forwarded, "Lang": old.Lang} {
		if value != "" {
			result[key] = value
		}
	}
	return result
}
