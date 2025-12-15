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

ARG APACHE_HTTP_SERVER_VERSION="2.4.66"
ARG APACHE_HTTP_SERVER_IMAGE="ghcr.io/yockow/swift-de-cgi-deps:ApacheHTTPServer_${APACHE_HTTP_SERVER_VERSION}-${BASE_OS_LABEL}"
ARG APACHE_HTTP_SERVER_INSTALL_PREFIX="/opt/ApacheHTTPServer"

ARG EXPAT_INSTALL_PREFIX="/opt/Expat"
ARG LIBXML2_INSTALL_PREFIX="/opt/libxml2"
ARG LUA_INSTALL_PREFIX="/opt/Lua"
ARG NGHTTP2_INSTALL_PREFIX="/opt/nghttp2"
ARG OPENSSL_INSTALL_PREFIX="/opt/OpenSSL"
ARG PCRE2_INSTALL_PREFIX="/opt/PCRE2"
ARG ZLIB_INSTALL_PREFIX="/opt/zlib"

ARG SWIFT_VERSION="6.2.3"
ARG SWIFT_GIT_TAG="swift-${SWIFT_VERSION}-RELEASE"
ARG SWIFT_IMAGE="swift:${SWIFT_VERSION}-${BASE_OS_LABEL}-slim"
ARG SWIFT_LIB_DIR="/usr/lib/swift/linux"

################################################################################
FROM $APACHE_HTTP_SERVER_IMAGE AS apache-http-server-image

################################################################################
FROM ubuntu:noble AS swift-license-fetcher

RUN apt update && apt install -y wget

ARG LICENSES_DIR
ARG SWIFT_GIT_TAG
RUN <<__LICENSE_COMMANDS__
mkdir -p "${LICENSES_DIR}/metadata"
wget -q -O "${LICENSES_DIR}/Swift.txt" \
       "https://raw.githubusercontent.com/swiftlang/swift/refs/tags/${SWIFT_GIT_TAG}/LICENSE.txt"
cat <<_LICENSE_METADATA_ >"${LICENSES_DIR}/metadata/Swift.json"
{
    "name": "Swift",
    "url": "https://www.swift.org/",
    "version": "${SWIFT_VERSION}",
    "filenames": {
        "LICENSE.txt": "Swift.txt"
    }
}
_LICENSE_METADATA_
__LICENSE_COMMANDS__

################################################################################
FROM $SWIFT_IMAGE

ARG APACHE_HTTP_SERVER_INSTALL_PREFIX
ENV APACHE_HTTP_SERVER_INSTALL_PREFIX="$APACHE_HTTP_SERVER_INSTALL_PREFIX"

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

ARG WWW_USER_NAME="swifche"
ARG WWW_GROUP_NAME="swifche"
ARG WWW_USER_ID="1450"
ARG WWW_GROUP_ID="1450"
ENV WWW_USER_NAME="$WWW_USER_NAME"
ENV WWW_GROUP_NAME="$WWW_GROUP_NAME"
ENV WWW_USER_ID="$WWW_USER_ID"
ENV WWW_GROUP_ID="$WWW_GROUP_ID"

COPY ./tools/show-licenses /usr/local/bin/show-licenses
COPY ./tools/entrypoint /entrypoint
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
	--mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update \
    && apt-get install -y --no-install-recommends \
        gosu \
        tini \
    && chmod 755 /usr/local/bin/show-licenses \
    && chmod 755 /entrypoint \
    && groupadd --gid "$WWW_GROUP_ID" "$WWW_GROUP_NAME" \
    && useradd --create-home --no-log-init --gid "$WWW_GROUP_ID" --uid "$WWW_USER_ID"  "$WWW_USER_NAME"

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

STOPSIGNAL SIGWINCH
ENTRYPOINT ["/usr/bin/tini", "--", "/entrypoint"]
