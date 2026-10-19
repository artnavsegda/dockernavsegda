# build
FROM alpine:latest AS build
RUN apk add --no-cache build-base cmake git json-c-dev

# runtime
FROM alpine:latest
RUN apk add --no-cache lighttpd lighttpd-mod_scgi