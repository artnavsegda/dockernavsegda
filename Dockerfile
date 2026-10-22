# OpenWRT 24.10 rootfs running procd as PID 1: ubusd, netifd, rpcd, uhttpd,
# logd and friends come up exactly like on a real router.

ARG OPENWRT_VERSION=24.10.8

# fetch + verify the official rootfs tarball for the host architecture
FROM alpine:latest AS rootfs
ARG OPENWRT_VERSION
ARG TARGETARCH
RUN apk add --no-cache curl
WORKDIR /dl
RUN set -eu; \
    case "$TARGETARCH" in \
      arm64) TARGET=armsr/armv8; NAME=armsr-armv8 ;; \
      amd64) TARGET=x86/64;      NAME=x86-64 ;; \
      *) echo "unsupported arch: $TARGETARCH" >&2; exit 1 ;; \
    esac; \
    BASE="https://downloads.openwrt.org/releases/${OPENWRT_VERSION}/targets/${TARGET}"; \
    FILE="openwrt-${OPENWRT_VERSION}-${NAME}-rootfs.tar.gz"; \
    curl -fsSLO "$BASE/$FILE"; \
    curl -fsSL "$BASE/sha256sums" | grep " \*$FILE\$" | sed 's/ \*/  /' | sha256sum -c -; \
    mkdir /rootfs; tar -xzf "$FILE" -C /rootfs

FROM scratch
COPY --from=rootfs /rootfs/ /

# opkg wants /var/lock, which lives on /tmp. ujail needs pivot_root, which an
# unprivileged container can't do, so services run unjailed instead.
# The web frontend is our own, served by lighttpd instead of LuCI/uhttpd;
# lighttpd runs as root like uhttpd does, so CGI/SCGI apps get full ubus access.
RUN mkdir -p /var/lock \
 && opkg update \
 && opkg install \
      ucode-mod-uloop ucode-mod-socket ucode-mod-rtnl ucode-mod-nl80211 \
      ucode-mod-log ucode-mod-struct ucode-mod-digest ucode-mod-resolv \
      ucode-mod-debug \
      rpcd-mod-ucode rpcd-mod-file rpcd-mod-iwinfo rpcd-mod-rpcsys \
      iwinfo ip-full nano less \
      lighttpd lighttpd-mod-cgi lighttpd-mod-scgi \
 && opkg remove procd-ujail \
 && opkg remove --force-removal-of-dependent-packages \
      luci luci-* uhttpd uhttpd-mod-ubus rpcd-mod-luci \
      liblucihttp-ucode liblucihttp0 \
 && rm -rf /tmp/opkg-lists /www/* \
 && sed -i '/^server\.\(username\|groupname\)/d' /etc/lighttpd/lighttpd.conf

COPY files/ /

EXPOSE 22 80
STOPSIGNAL SIGUSR2
CMD ["/sbin/docker-init"]
