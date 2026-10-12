package controllers

import (
	"context"
	"encoding/json"
	"encoding/xml"
	"errors"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"
)

func handler(t *testing.T) *Handler {
	t.Helper()
	h, err := NewHandler("../views", "../static")
	if err != nil {
		t.Fatal(err)
	}
	h.lookup = func(ctx context.Context, ip string) ([]string, error) {
		if ip == "8.8.8.8" {
			return []string{"dns.google."}, nil
		}
		return nil, errors.New("no PTR")
	}
	return h
}
func request(h *Handler, method, path string, headers map[string]string) *httptest.ResponseRecorder {
	r := httptest.NewRequest(method, path, nil)
	r.RemoteAddr = "127.0.0.1:4321"
	for key, value := range headers {
		r.Header.Set(key, value)
	}
	w := httptest.NewRecorder()
	h.ServeHTTP(w, r)
	return w
}
func TestSource(t *testing.T) {
	for _, c := range []struct{ name, remote, forwarded, port, ip, wantPort string }{
		{"ipv4", "192.0.2.1:123", "", "", "192.0.2.1", "123"},
		{"ipv6", "[2001:db8::1]:123", "", "", "2001:db8::1", "123"},
		{"mapped", "[::ffff:192.0.2.1]:123", "", "", "192.0.2.1", "123"},
		{"proxy", "127.0.0.1:123", "8.8.8.8", "456", "8.8.8.8", "456"},
		{"v6proxy", "[::1]:123", "2001:db8::2", "456", "2001:db8::2", "456"},
		{"untrusted", "192.0.2.1:123", "8.8.8.8", "456", "192.0.2.1", "123"},
		{"missingport", "127.0.0.1:123", "8.8.8.8", "", "8.8.8.8", ""},
		{"badport", "127.0.0.1:123", "8.8.8.8", "65536", "8.8.8.8", ""},
		{"badip", "127.0.0.1:123", "bad", "456", "127.0.0.1", "123"},
		{"bare", "192.0.2.1", "", "", "192.0.2.1", ""},
	} {
		t.Run(c.name, func(t *testing.T) {
			r := httptest.NewRequest("GET", "/ip", nil)
			r.RemoteAddr = c.remote
			r.Header.Set("X-Tih-Forwarded-For", c.forwarded)
			r.Header.Set("X-Tih-Forwarded-For-Port", c.port)
			ip, port := source(r)
			if ip != c.ip || port != c.wantPort {
				t.Fatalf("got %s:%s want %s:%s", ip, port, c.ip, c.wantPort)
			}
		})
	}
}
func TestRepresentations(t *testing.T) {
	h := handler(t)
	headers := map[string]string{"X-Tih-Forwarded-For": "8.8.8.8", "X-Tih-Forwarded-For-Port": "456", "User-Agent": "example & <tag> \"quoted\"", "Keep-Alive": "timeout=5", "Accept-Charset": "utf-8"}
	w := request(h, "GET", "/all.json", headers)
	var info Info
	if err := json.Unmarshal(w.Body.Bytes(), &info); err != nil {
		t.Fatal(err)
	}
	if info.IP != "8.8.8.8" || info.Host != "dns.google" || info.Port != "456" || info.UserAgent != headers["User-Agent"] {
		t.Fatalf("bad json: %+v", info)
	}
	var fields map[string]any
	_ = json.Unmarshal(w.Body.Bytes(), &fields)
	if fields["ip_addr"] != "8.8.8.8" || fields["remote_host"] != "dns.google" {
		t.Fatal(fields)
	}
	w = request(h, "GET", "/all.xml", headers)
	var xmlInfo Info
	if err := xml.Unmarshal(w.Body.Bytes(), &xmlInfo); err != nil {
		t.Fatal(err)
	}
	if xmlInfo.XMLName.Local != "info" || xmlInfo.Host != info.Host || xmlInfo.IP != info.IP {
		t.Fatalf("bad xml: %+v", xmlInfo)
	}
	for path, want := range map[string]string{"/host": "dns.google\n", "/ua": headers["User-Agent"] + "\n", "/keepalive": "timeout=5\n", "/charset": "utf-8\n", "/port": "456\n", "/ip": "8.8.8.8\n"} {
		w = request(h, "GET", path, headers)
		if w.Code != 200 || w.Body.String() != want || w.Header().Get("Content-Type") != "text/plain; charset=utf-8" {
			t.Fatalf("%s: %d %q", path, w.Code, w.Body.String())
		}
	}
	w = request(h, "GET", "/", headers)
	if strings.Contains(w.Body.String(), "example & <tag>") || !strings.Contains(w.Body.String(), "example &amp; &lt;tag&gt;") || !strings.Contains(w.Body.String(), "dns.google") {
		t.Fatal("HTML escaping or host failed")
	}
	w = request(h, "GET", "/all.json?format=legacy", headers)
	_ = json.Unmarshal(w.Body.Bytes(), &fields)
	if fields["IP"] != "8.8.8.8" || fields["Host"] != "dns.google\n" {
		t.Fatal("legacy JSON failed")
	}
	w = request(h, "GET", "/all.xml?format=legacy", headers)
	var old oldInfo
	if err := xml.Unmarshal(w.Body.Bytes(), &old); err != nil || old.XMLName.Local != "ifconfig" || old.IP != "8.8.8.8" {
		t.Fatal("legacy XML failed", err)
	}
}
func TestMethodsAndMissingPort(t *testing.T) {
	h := handler(t)
	headers := map[string]string{"X-Tih-Forwarded-For": "8.8.8.8"}
	for _, path := range []string{"/", "/ip", "/host", "/ua", "/port", "/keepalive", "/lang", "/connection", "/encoding", "/via", "/mime", "/charset", "/forwarded", "/all", "/all.xml", "/all.json"} {
		for _, method := range []string{"GET", "HEAD", "OPTIONS"} {
			w := request(h, method, path, headers)
			want := 200
			if method == "OPTIONS" {
				want = 204
			}
			if w.Code != want || w.Header().Get("Cache-Control") != "no-store" {
				t.Fatalf("%s %s: %d", method, path, w.Code)
			}
		}
	}
	if request(h, "POST", "/ip", nil).Code != 405 || request(h, "GET", "/missing", nil).Code != 404 {
		t.Fatal("wrong method/path status")
	}
	// net/http must suppress the body for HEAD, beyond recorder-level checks.
	s := httptest.NewServer(h)
	defer s.Close()
	r, err := http.Head(s.URL + "/ip")
	if err != nil {
		t.Fatal(err)
	}
	defer r.Body.Close()
	var one [1]byte
	if n, _ := r.Body.Read(one[:]); n != 0 || r.StatusCode != 200 {
		t.Fatal("HEAD response body/status")
	}
}
func TestDNSCacheAndDeadline(t *testing.T) {
	h := handler(t)
	calls := 0
	h.lookup = func(ctx context.Context, ip string) ([]string, error) {
		calls++
		if _, ok := ctx.Deadline(); !ok {
			t.Fatal("lookup without deadline")
		}
		return []string{"dns.google."}, nil
	}
	for i := 0; i < 2; i++ {
		if h.hostname(context.Background(), "8.8.8.8") != "dns.google" {
			t.Fatal("lookup failed")
		}
	}
	if calls != 1 {
		t.Fatal("PTR cache unused")
	}
	request(h, "GET", "/ip", nil)
	request(h, "GET", "/", map[string]string{"User-Agent": "curl/8.0"})
	if calls != 1 {
		t.Fatal("plain IP request performs DNS lookup")
	}
}
