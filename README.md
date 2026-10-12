# ifconfig.tw

IP and request information service written with the Go standard library. There
are no third-party runtime dependencies. Go 1.22 or later is required.

## Build and test

```sh
go test -race ./...
go vet ./...
CGO_ENABLED=0 go build -trimpath -o ifconfig .
./ifconfig -addr 127.0.0.1:1980
```

Run from the project directory so `views/` and `static/` are available, or set
`-views` and `-static`. `NOWEB=1` disables the root endpoint.

## API

All listed routes support GET, HEAD and OPTIONS. Unsupported methods return 405;
unknown routes return 404. Responses are marked `Cache-Control: no-store`.

- `/`: HTML for browsers; plain IP for curl user agents.
- `/ip`, `/host`, `/ua`, `/port`, `/lang`, `/keepalive`, `/connection`, `/encoding`,
  `/mime`, `/charset`, `/via`, `/forwarded`: plain UTF-8 values, with a final newline.
- `/all`: plain text fields.
- `/all.json`: JSON with stable snake_case fields, including `ip_addr`,
  `remote_host`, `user_agent`, `port`, `lang`, `connection`, `keep_alive`,
  `encoding`, `mime`, `charset`, `via`, `forwarded`, `method`, `referer`, `email`.
  Missing values are empty strings, not omitted.
- `/all.xml`: the same fields within an `<info>` root element.
- `/all.json?format=legacy` and `/all.xml?format=legacy`: previous capitalized
  fields and XML `<ifconfig>` root for clients migrating from the old API.

`charset` reads Accept-Charset, `keep_alive` reads Keep-Alive, and `mime` reads
Accept. Headers reflect the request received by the service; hop-by-hop headers
such as Connection may be changed by nginx. Forwarded headers are informational,
not authenticated client identity. PTR lookup uses the resolved client IP, a
one-second deadline and a bounded five-minute cache; failure produces an empty
host. IP-only requests perform no PTR lookup.

## Deployment

Use nginx for public HTTP/HTTPS and ACME challenges. The application defaults
to **127.0.0.1:1980**, has no TLS listener, and never reads certificate keys.
Nginx must overwrite X-Tih-Forwarded-For and X-Tih-Forwarded-For-Port with
`$remote_addr` and `$remote_port`. To expose the original Keep-Alive diagnostic
value, also set `proxy_set_header Keep-Alive $http_keep_alive;`; nginx otherwise
removes it. The application trusts the source headers only from
loopback peers; do not expose the backend or route arbitrary proxies through it.

Install the binary, `views/` and `static/` in `/opt/ifconfig.tw`, owned by root and
readable by the unprivileged `ifconfig` system user. Install
`deploy/ifconfig.tw.service` in `/etc/systemd/system/`, then enable the service.
The old `conf/app.conf` is retained as a migration note and is no longer read.
Nginx is solely responsible for certificate renewal and reloads.

Each production change should have a backup of the original source, binary,
nginx configuration and service definition. The deployment backup includes a
rollback script. Rebuild with `build/build.sh`; set GOOS/GOARCH for cross builds.

## AdSense onboarding

The homepage includes the publisher verification meta tag for
`ca-pub-1687667848944125`. `static/ads.txt` provides the authorized Google seller
entry. The nginx configuration maps `/ads.txt` and `/privacy` to the corresponding
static files; keep those mappings when installing the deployment snapshot.
The homepage links to privacy/advertising disclosures and explains the tool's
connection fields and API usage.

Site ownership was verified and site review requested on 2026-10-12. No AdSense
ad-serving script or ad unit is enabled yet. Check the AdSense dashboard for site
approval and complete the required account/payment information before enabling
ads. Use a single manually placed responsive display unit at the header, keeping
it away from the IP data and command-line examples. Configure Google's certified
CMP/European regulations message before enabling ads for the relevant regions.

References:
- https://support.google.com/adsense/answer/7584263
- https://support.google.com/adsense/answer/12171612
- https://support.google.com/adsense/answer/1348695
- https://support.google.com/adsense/answer/13554116
