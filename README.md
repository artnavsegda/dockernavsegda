# dockernavsegda
OpenWRT 24.10 in Docker for ucode testing

Official OpenWRT 24.10 rootfs (armsr/armv8 on Apple Silicon/arm64, x86/64 on
amd64) booted with procd as PID 1, so `ubusd`, `rpcd`, `netifd`, `logd`,
`dnsmasq`, `dropbear` run as on a real router. LuCI and uhttpd are removed;
the web server is lighttpd with mod_cgi and mod_scgi for our own frontend. Extra ucode
modules (uloop, socket, rtnl, nl80211, log, struct, digest, resolv, debug)
and rpcd plugins are preinstalled.

```sh
docker compose up -d --build
docker compose exec openwrt ubus list
docker compose exec openwrt ucode /root/scripts/info.uc
docker compose exec -it openwrt ash
```

- `scripts/` is mounted at `/root/scripts`, `www/` is the
  lighttpd document root `/www`: http://localhost:8080 (`*.uc` run as ucode CGI).
- lighttpd config: `files/etc/lighttpd/conf.d/90-frontend.conf` (SCGI
  example inside). It runs as root like uhttpd, so CGI/SCGI have full ubus access.
- ssh on port 2222 (`root`, empty password).
- rpcd ACL `dev-full` (`files/usr/share/rpcd/acl.d/dev-full.json`) gives
  a `session.login` as `root` full ubus/uci/file access. Development only.
- `lan` is `eth0` with the address Docker assigned (refreshed on every start);
  DHCP/RA on it and ntpd are disabled. ujail is removed (no `pivot_root` in an
  unprivileged container). No Wi-Fi radios, so `network.wireless`/`iwinfo` are empty.
- Board identity (`openwrt,docker` / `OpenWrt Docker`) comes from
  `files/etc/board.json`; a preinit hook also feeds `model.id`/`model.name`
  to `ubus call system board`.
