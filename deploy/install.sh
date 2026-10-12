#!/bin/bash
set -euo pipefail
migration=/root/ifconfig-migration-20261012
source_dir=/root/ifconfig.tw/src/github.com/PichuChen/ifconfig
stage=$migration/stage
backup=$migration/backup
if test -e "$backup"; then
  echo "Backup already exists; inspect migration state before retrying" >&2
  exit 1
fi
mkdir -m 700 "$backup"
tar -C "$source_dir" -czf "$backup/source.tar.gz" .
cp /etc/nginx/sites-enabled/ifconfig.tw "$backup/nginx.conf"
if test -f /etc/systemd/system/ifconfig.tw.service; then
  cp /etc/systemd/system/ifconfig.tw.service "$backup/ifconfig.tw.service"
fi
cat > "$backup/rollback.sh" <<'ROLLBACK'
#!/bin/bash
set -euo pipefail
backup=/root/ifconfig-migration-20261012/backup
source_dir=/root/ifconfig.tw/src/github.com/PichuChen/ifconfig
systemctl disable --now ifconfig.tw.service || true
# Remove only files introduced by this migration before restoring the snapshot.
rm -f "$source_dir/go.mod" "$source_dir/build/build.sh" \
 "$source_dir/deploy/ifconfig.tw.service" "$source_dir/deploy/install.sh" \
 "$source_dir/deploy/ifconfig.tw.nginx.conf"
rmdir "$source_dir/deploy" 2>/dev/null || true
tar -C "$source_dir" -xzf "$backup/source.tar.gz"
cp "$backup/nginx.conf" /etc/nginx/sites-enabled/ifconfig.tw
if test -f "$backup/ifconfig.tw.service"; then
  cp "$backup/ifconfig.tw.service" /etc/systemd/system/ifconfig.tw.service
else
  cat > /etc/systemd/system/ifconfig.tw.service <<'UNIT'
[Unit]
Description=ifconfig.tw original binary (rollback)
After=network.target
[Service]
WorkingDirectory=/root/ifconfig.tw/src/github.com/PichuChen/ifconfig
ExecStart=/root/ifconfig.tw/src/github.com/PichuChen/ifconfig/ifconfig
Restart=on-failure
[Install]
WantedBy=multi-user.target
UNIT
fi
systemctl daemon-reload
systemctl enable --now ifconfig.tw.service
nginx -t
systemctl reload nginx
ROLLBACK
chmod 700 "$backup/rollback.sh"
nginx -t
if ! getent passwd ifconfig >/dev/null; then
 useradd --system --home-dir /nonexistent --no-create-home --shell /usr/sbin/nologin ifconfig
fi
install -d -o root -g root -m 755 /opt/ifconfig.tw
install -o root -g root -m 755 "$stage/ifconfig" /opt/ifconfig.tw/ifconfig
rsync -a --chown=root:root "$stage/views" "$stage/static" /opt/ifconfig.tw/
find /opt/ifconfig.tw/views /opt/ifconfig.tw/static -type d -exec chmod 755 {} +
find /opt/ifconfig.tw/views /opt/ifconfig.tw/static -type f -exec chmod 644 {} +
install -o root -g root -m 644 "$stage/deploy/ifconfig.tw.service" /etc/systemd/system/ifconfig.tw.service
systemd-analyze verify /etc/systemd/system/ifconfig.tw.service
# Use a separate loopback port to validate the installed files and user before
# replacing the existing process on 1980.
runuser -u ifconfig -- sh -c 'cd /opt/ifconfig.tw && exec ./ifconfig -addr 127.0.0.1:1981' > "$migration/staging.log" 2>&1 &
staging_pid=$!
trap 'kill "$staging_pid" 2>/dev/null || true' EXIT
python3 - <<'PY'
import time,urllib.request,json
for attempt in range(30):
 try:
  with urllib.request.urlopen('http://127.0.0.1:1981/all.json',timeout=2) as r:
   info=json.load(r)
   assert info['ip_addr']=='127.0.0.1',info
   assert r.headers['Cache-Control']=='no-store'
   print('Unprivileged staging service passed')
   break
 except OSError:
  time.sleep(.1)
else: raise RuntimeError('Staging service did not start')
PY
kill "$staging_pid"
wait "$staging_pid" || true
trap - EXIT
# Deploy only known project files; preserve .git, historical artifacts and binary
# backups. No remote publication is performed.
rsync -a --chown=root:root --exclude=.git --exclude=ifconfig --exclude=certbot-auto "$stage/" "$source_dir/"
install -m 755 "$stage/ifconfig" "$source_dir/ifconfig.new"
mv "$source_dir/ifconfig.new" "$source_dir/ifconfig"
python3 - <<'PY'
from pathlib import Path
p=Path('/etc/nginx/sites-enabled/ifconfig.tw')
s=p.read_text().replace('proxy_pass http://localhost:1980;', 'proxy_pass http://127.0.0.1:1980;')
s=s.replace('proxy_set_header X-Tih-Forwarded-For-Port $remote_port;', 'proxy_set_header X-Tih-Forwarded-For-Port $remote_port;\n                proxy_set_header Keep-Alive $http_keep_alive;')
p.write_text(s)
PY
nginx -t
# Limit termination to the old binary from this exact checkout.
python3 - <<'PY'
import os,signal,time
from pathlib import Path
expected='/root/ifconfig.tw/src/github.com/PichuChen/ifconfig'
old=[]
for proc in Path('/proc').iterdir():
 if not proc.name.isdigit(): continue
 try:
  exe=os.readlink(proc/'exe')
  if os.readlink(proc/'cwd')==expected and exe.split(' (deleted)')[0]==expected+'/ifconfig':
   old.append(int(proc.name))
 except OSError: pass
for pid in old:
 os.kill(pid,signal.SIGTERM)
for attempt in range(100):
 if not any(Path(f'/proc/{pid}').exists() for pid in old): break
 time.sleep(.1)
else: raise RuntimeError('Old process did not terminate; no SIGKILL used')
print('Stopped original PIDs',old)
PY
systemctl daemon-reload
systemctl enable --now ifconfig.tw.service
python3 - <<'PY'
import time,urllib.request,json
for attempt in range(30):
 try:
  with urllib.request.urlopen('http://127.0.0.1:1980/all.json',timeout=2) as r:
   assert json.load(r)['ip_addr']=='127.0.0.1'
   break
 except OSError: time.sleep(.1)
else: raise RuntimeError('New production service did not start; run backup/rollback.sh')
PY
systemctl reload nginx
systemctl --no-pager --full status ifconfig.tw.service
