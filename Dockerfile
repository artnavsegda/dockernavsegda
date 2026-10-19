# build
FROM alpine:latest AS build
RUN apk add --no-cache build-base cmake git json-c-dev
WORKDIR /src

RUN git clone --depth 1 https://git.openwrt.org/project/libubox.git \
 && cmake -S libubox -B libubox/build -DCMAKE_INSTALL_PREFIX=/usr \
      -DBUILD_LUA=OFF -DBUILD_EXAMPLES=OFF \
 && cmake --build libubox/build -j"$(nproc)" \
 && cmake --install libubox/build \
 && DESTDIR=/stage cmake --install libubox/build

RUN git clone --depth 1 https://git.openwrt.org/project/ubus.git \
 && cmake -S ubus -B ubus/build -DCMAKE_INSTALL_PREFIX=/usr \
      -DBUILD_LUA=OFF -DBUILD_EXAMPLES=OFF \
 && cmake --build ubus/build -j"$(nproc)" \
 && cmake --install ubus/build \
 && DESTDIR=/stage cmake --install ubus/build

RUN git clone --depth 1 https://github.com/jow-/ucode.git \
 && cmake -S ucode -B ucode/build -DCMAKE_INSTALL_PREFIX=/usr \
      -DUBUS_SUPPORT=ON -DULOOP_SUPPORT=ON \
      -DUCI_SUPPORT=OFF -DRTNL_SUPPORT=OFF -DNL80211_SUPPORT=OFF \
 && cmake --build ucode/build -j"$(nproc)" \
 && DESTDIR=/stage cmake --install ucode/build

# runtime
FROM alpine:latest
RUN apk add --no-cache lighttpd lighttpd-mod_scgi