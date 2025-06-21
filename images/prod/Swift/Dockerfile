################################################################################
#
# images/prod/Swift/Dockerfile
#
# © 2025 YOCKOW.
#     Licensed under MIT License.
#     See "LICENSE.txt" for more information.
#
################################################################################

# Configurable arguments
ARG BASE_UBUNTU_VERSION="noble"
ARG BASE_OS_LABEL="noble"
ARG BASE_OS_IMAGE="ubuntu:${BASE_UBUNTU_VERSION}"

ARG LICENSES_DIR="/licenses"

ARG APACHE_HTTP_SERVER_VERSION="2.4.63"
ARG APACHE_HTTP_SERVER_IMAGE="ghcr.io/yockow/swift-de-cgi-deps:ApacheHTTPServer_${APACHE_HTTP_SERVER_VERSION}-${BASE_OS_LABEL}"
ARG APACHE_HTTP_SERVER_INSTALL_PREFIX="/opt/ApacheHTTPServer"

ARG EXPAT_INSTALL_PREFIX="/opt/Expat"
ARG LIBXML2_INSTALL_PREFIX="/opt/libxml2"
ARG LUA_INSTALL_PREFIX="/opt/Lua"
ARG NGHTTP2_INSTALL_PREFIX="/opt/nghttp2"
ARG OPENSSL_INSTALL_PREFIX="/opt/OpenSSL"
ARG PCRE2_INSTALL_PREFIX="/opt/PCRE2"
ARG ZLIB_INSTALL_PREFIX="/opt/zlib"

ARG SWIFT_VERSION="6.1.2"
ARG SWIFT_IMAGE="swift:${SWIFT_VERSION}-${BASE_OS_LABEL}-slim"
ARG SWIFT_LIB_DIR="/usr/lib/swift/linux"

################################################################################
FROM $APACHE_HTTP_SERVER_IMAGE AS apache-http-server-image

################################################################################
FROM ubuntu:noble AS swift-license-fetcher

RUN apt update && apt install -y wget

ARG LICENSES_DIR
ARG SWIFT_VERSION
RUN mkdir -p "${LICENSES_DIR}" \
    && wget -q -O "${LICENSES_DIR}/Swift.txt" \
       "https://raw.githubusercontent.com/swiftlang/swift/refs/tags/swift-${SWIFT_VERSION}-RELEASE/LICENSE.txt"

################################################################################
FROM $SWIFT_IMAGE

ARG APACHE_HTTP_SERVER_INSTALL_PREFIX
ARG EXPAT_INSTALL_PREFIX
ARG LIBXML2_INSTALL_PREFIX
ARG LUA_INSTALL_PREFIX
ARG NGHTTP2_INSTALL_PREFIX
ARG OPENSSL_INSTALL_PREFIX
ARG PCRE2_INSTALL_PREFIX
ARG ZLIB_INSTALL_PREFIX

ARG LICENSES_DIR

ARG SWIFT_LIB_DIR
ENV SWIFT_LIB_DIR="$SWIFT_LIB_DIR"

COPY --from=apache-http-server-image $APACHE_HTTP_SERVER_INSTALL_PREFIX $APACHE_HTTP_SERVER_INSTALL_PREFIX
COPY --from=apache-http-server-image $EXPAT_INSTALL_PREFIX $EXPAT_INSTALL_PREFIX
COPY --from=apache-http-server-image $LIBXML2_INSTALL_PREFIX $LIBXML2_INSTALL_PREFIX
COPY --from=apache-http-server-image $LUA_INSTALL_PREFIX $LUA_INSTALL_PREFIX
COPY --from=apache-http-server-image $NGHTTP2_INSTALL_PREFIX $NGHTTP2_INSTALL_PREFIX
COPY --from=apache-http-server-image $OPENSSL_INSTALL_PREFIX $OPENSSL_INSTALL_PREFIX
COPY --from=apache-http-server-image $PCRE2_INSTALL_PREFIX $PCRE2_INSTALL_PREFIX
COPY --from=apache-http-server-image $ZLIB_INSTALL_PREFIX $ZLIB_INSTALL_PREFIX

COPY --from=apache-http-server-image $LICENSES_DIR $LICENSES_DIR
COPY --from=swift-license-fetcher $LICENSES_DIR $LICENSES_DIR

COPY ./tools/show-licenses /usr/local/bin/show-licenses
RUN chmod 755 /usr/local/bin/show-licenses