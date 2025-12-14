################################################################################
#
# images/deps/ApacheHTTPServer/Dockerfile
#
# © 2025 YOCKOW.
#     Licensed under MIT License.
#     See "LICENSE.txt" for more information.
#
################################################################################

# Configurable arguments
ARG BASE_UBUNTU_VERSION="noble"
ARG BASE_OS_IMAGE="ubuntu:${BASE_UBUNTU_VERSION}"
ARG BASE_OS_LABEL="noble"

ARG LICENSES_DIR="/licenses"

ARG APACHE_HTTP_SERVER_VERSION="2.4.66"
ARG APACHE_APR_VERSION="1.7.6"
ARG APACHE_APRUTIL_VERSION="1.6.3"
ARG APACHE_HTTP_SERVER_INSTALL_PREFIX="/opt/ApacheHTTPServer"
ARG APACHE_DOWNLOAD_WEB_ROOT="https://dlcdn.apache.org"
ARG APACHE_HTTP_SERVER_KEYS_URL="https://downloads.apache.org/httpd/KEYS"
ARG APACHE_APR_KEYS_URL="https://downloads.apache.org/apr/KEYS"

ARG EXPAT_VERSION="2.7.3"
ARG EXPAT_IMAGE="ghcr.io/yockow/swift-de-cgi-deps:Expat_${EXPAT_VERSION}-${BASE_OS_LABEL}"
ARG EXPAT_INSTALL_PREFIX="/opt/Expat"

ARG LIBXML2_VERSION="2.15.1"
ARG LIBXML2_IMAGE="ghcr.io/yockow/swift-de-cgi-deps:libxml2_${LIBXML2_VERSION}-${BASE_OS_LABEL}"
ARG LIBXML2_INSTALL_PREFIX="/opt/libxml2"

ARG LUA_VERSION="5.4.8"
ARG LUA_IMAGE="ghcr.io/yockow/swift-de-cgi-deps:Lua_${LUA_VERSION}-${BASE_OS_LABEL}"
ARG LUA_INSTALL_PREFIX="/opt/Lua"

ARG NGHTTP2_VERSION="1.68.0"
ARG NGHTTP2_IMAGE="ghcr.io/yockow/swift-de-cgi-deps:nghttp2_${NGHTTP2_VERSION}-${BASE_OS_LABEL}"
ARG NGHTTP2_INSTALL_PREFIX="/opt/nghttp2"

ARG OPENSSL_VERSION="3.6.0"
ARG OPENSSL_IMAGE="ghcr.io/yockow/swift-de-cgi-deps:OpenSSL_${OPENSSL_VERSION}-${BASE_OS_LABEL}"
ARG OPENSSL_INSTALL_PREFIX="/opt/OpenSSL"

ARG PCRE2_VERSION="10.47"
ARG PCRE2_IMAGE="ghcr.io/yockow/swift-de-cgi-deps:PCRE2_${PCRE2_VERSION}-${BASE_OS_LABEL}"
ARG PCRE2_INSTALL_PREFIX="/opt/PCRE2"

ARG ZLIB_VERSION="1.3.1"
ARG ZLIB_IMAGE="ghcr.io/yockow/swift-de-cgi-deps:zlib_${ZLIB_VERSION}-${BASE_OS_LABEL}"
ARG ZLIB_INSTALL_PREFIX="/opt/zlib"

################################################################################
FROM $EXPAT_IMAGE AS expat-image
FROM $LIBXML2_IMAGE AS libxml2-image
FROM $LUA_IMAGE AS lua-image
FROM $NGHTTP2_IMAGE AS nghttp2-image
FROM $OPENSSL_IMAGE AS openssl-image
FROM $PCRE2_IMAGE AS pcre2-image
FROM $ZLIB_IMAGE AS zlib-image

################################################################################
FROM $BASE_OS_IMAGE AS apache-http-server-builder

ARG LICENSES_DIR
ARG APACHE_HTTP_SERVER_VERSION
ARG APACHE_APR_VERSION
ARG APACHE_APRUTIL_VERSION
ARG APACHE_DOWNLOAD_WEB_ROOT
ARG APACHE_HTTP_SERVER_KEYS_URL
ARG APACHE_APR_KEYS_URL
ARG APACHE_HTTP_SERVER_INSTALL_PREFIX
ARG EXPAT_INSTALL_PREFIX
ARG LIBXML2_INSTALL_PREFIX
ARG LUA_INSTALL_PREFIX
ARG NGHTTP2_INSTALL_PREFIX
ARG OPENSSL_INSTALL_PREFIX
ARG PCRE2_INSTALL_PREFIX
ARG ZLIB_INSTALL_PREFIX

ENV APACHE_WORKSPACE="/workspace"
ENV APACHE_HTTP_SERVER_BIN_URL="${APACHE_DOWNLOAD_WEB_ROOT}/httpd/httpd-${APACHE_HTTP_SERVER_VERSION}.tar.gz" \
    APACHE_HTTP_SERVER_SIG_URL="${APACHE_DOWNLOAD_WEB_ROOT}/httpd/httpd-${APACHE_HTTP_SERVER_VERSION}.tar.gz.asc" \
    APACHE_HTTP_SERVER_BIN_LOCAL_BASENAME="httpd.tar.gz" \
    APACHE_HTTP_SERVER_SIG_LOCAL_BASENAME="httpd.tar.gz.asc" \
    APACHE_APR_BIN_URL="${APACHE_DOWNLOAD_WEB_ROOT}/apr/apr-${APACHE_APR_VERSION}.tar.gz" \
    APACHE_APR_SIG_URL="${APACHE_DOWNLOAD_WEB_ROOT}/apr/apr-${APACHE_APR_VERSION}.tar.gz.asc" \
    APACHE_APR_BIN_LOCAL_BASENAME="apr.tar.gz" \
    APACHE_APR_SIG_LOCAL_BASENAME="apr.tar.gz.asc" \
    APACHE_APRUTIL_BIN_URL="${APACHE_DOWNLOAD_WEB_ROOT}/apr/apr-util-${APACHE_APRUTIL_VERSION}.tar.gz" \
    APACHE_APRUTIL_SIG_URL="${APACHE_DOWNLOAD_WEB_ROOT}/apr/apr-util-${APACHE_APRUTIL_VERSION}.tar.gz.asc" \
    APACHE_APRUTIL_BIN_LOCAL_BASENAME="apr-util.tar.gz" \
    APACHE_APRUTIL_SIG_LOCAL_BASENAME="apr-util.tar.gz.asc" \
    APACHE_HTTP_SERVER_SOURCE_DIR="${APACHE_WORKSPACE}/ApacheHTTPServer" \
    GNUPGHOME="${APACHE_WORKSPACE}/.gpg" \
    PCRE_CONFIG="${PCRE2_INSTALL_PREFIX}/bin/pcre2-config"

RUN apt update \
    && apt upgrade -y \
    && apt install -y \
        clang \
        gnupg2 \
        make \
        wget

RUN mkdir -p "$APACHE_WORKSPACE" "$APACHE_HTTP_SERVER_SOURCE_DIR" "$GNUPGHOME" \
    && chmod 600 "$GNUPGHOME"
RUN wget -q -O- "$APACHE_HTTP_SERVER_KEYS_URL" | gpg --import
RUN wget -q -O- "$APACHE_APR_KEYS_URL" | gpg --import

WORKDIR $APACHE_WORKSPACE
RUN wget -q -O "${APACHE_HTTP_SERVER_BIN_LOCAL_BASENAME}" "${APACHE_HTTP_SERVER_BIN_URL}" \
    && wget -q -O "${APACHE_HTTP_SERVER_SIG_LOCAL_BASENAME}" "${APACHE_HTTP_SERVER_SIG_URL}"
RUN gpg --batch --verify "${APACHE_HTTP_SERVER_SIG_LOCAL_BASENAME}" "${APACHE_HTTP_SERVER_BIN_LOCAL_BASENAME}" \
    && tar -xzf "${APACHE_HTTP_SERVER_BIN_LOCAL_BASENAME}" --directory "${APACHE_HTTP_SERVER_SOURCE_DIR}" --strip-components=1

RUN wget -q -O "${APACHE_APR_BIN_LOCAL_BASENAME}" "${APACHE_APR_BIN_URL}" \
    && wget -q -O "${APACHE_APR_SIG_LOCAL_BASENAME}" "${APACHE_APR_SIG_URL}"
RUN gpg --batch --verify "${APACHE_APR_SIG_LOCAL_BASENAME}" "${APACHE_APR_BIN_LOCAL_BASENAME}" \
    && mkdir -p "${APACHE_HTTP_SERVER_SOURCE_DIR}/srclib/apr" \
    && tar -xzf "${APACHE_APR_BIN_LOCAL_BASENAME}" --directory "${APACHE_HTTP_SERVER_SOURCE_DIR}/srclib/apr" --strip-components=1

RUN wget -q -O "${APACHE_APRUTIL_BIN_LOCAL_BASENAME}" "${APACHE_APRUTIL_BIN_URL}" \
    && wget -q -O "${APACHE_APRUTIL_SIG_LOCAL_BASENAME}" "${APACHE_APRUTIL_SIG_URL}"
RUN gpg --batch --verify "${APACHE_APRUTIL_SIG_LOCAL_BASENAME}" "${APACHE_APRUTIL_BIN_LOCAL_BASENAME}" \
    && mkdir -p "${APACHE_HTTP_SERVER_SOURCE_DIR}/srclib/apr-util" \
    && tar -xzf "${APACHE_APRUTIL_BIN_LOCAL_BASENAME}" --directory "${APACHE_HTTP_SERVER_SOURCE_DIR}/srclib/apr-util" --strip-components=1

COPY --from=expat-image $EXPAT_INSTALL_PREFIX $EXPAT_INSTALL_PREFIX
COPY --from=libxml2-image $LIBXML2_INSTALL_PREFIX $LIBXML2_INSTALL_PREFIX
COPY --from=lua-image $LUA_INSTALL_PREFIX $LUA_INSTALL_PREFIX
COPY --from=nghttp2-image $NGHTTP2_INSTALL_PREFIX $NGHTTP2_INSTALL_PREFIX
COPY --from=openssl-image $OPENSSL_INSTALL_PREFIX $OPENSSL_INSTALL_PREFIX
COPY --from=pcre2-image $PCRE2_INSTALL_PREFIX $PCRE2_INSTALL_PREFIX
COPY --from=zlib-image $ZLIB_INSTALL_PREFIX $ZLIB_INSTALL_PREFIX

WORKDIR $APACHE_HTTP_SERVER_SOURCE_DIR
ENV LDFLAGS="-Wl,-rpath,${APACHE_HTTP_SERVER_INSTALL_PREFIX}/lib,-rpath,${EXPAT_INSTALL_PREFIX}/lib,-rpath,${LIBXML2_INSTALL_PREFIX}/lib,-rpath,${LUA_INSTALL_PREFIX}/lib,-rpath,${NGHTTP2_INSTALL_PREFIX}/lib,-rpath,${OPENSSL_INSTALL_PREFIX}/lib,-rpath,${PCRE2_INSTALL_PREFIX}/lib,-rpath,${ZLIB_INSTALL_PREFIX}/lib -L${LIBXML2_INSTALL_PREFIX}/lib"
RUN ./configure \
        --prefix="$APACHE_HTTP_SERVER_INSTALL_PREFIX" \
        --with-included-apr --with-expat="$EXPAT_INSTALL_PREFIX" \
        --enable-mpms-shared=all \
        --enable-mods-shared=reallyall \
        --enable-deflate --with-z="$ZLIB_INSTALL_PREFIX" \
        --enable-lua --with-lua="$LUA_INSTALL_PREFIX" \
        --enable-proxy-html --enable-xml2enc --with-libxml2="$LIBXML2_INSTALL_PREFIX" \
        --enable-ssl --with-ssl="$OPENSSL_INSTALL_PREFIX" \
        --enable-http2 --with-nghttp2="$NGHTTP2_INSTALL_PREFIX" \
        --with-pcre="$PCRE2_INSTALL_PREFIX" \
        CC=clang CXX=clang++
RUN make && make install
RUN mkdir -p "${LICENSES_DIR}" \
    && cp ./LICENSE "${LICENSES_DIR}/Apache_HTTP_Server-LICENSE.txt" \
    && cp ./NOTICE  "${LICENSES_DIR}/Apache_HTTP_Server-NOTICE.txt" \
    && cp ./srclib/apr/LICENSE "${LICENSES_DIR}/Apache_Portable_Runtime-LICENSE.txt" \
    && cp ./srclib/apr/NOTICE  "${LICENSES_DIR}/Apache_Portable_Runtime-NOTICE.txt" \
    && cp ./srclib/apr-util/LICENSE "${LICENSES_DIR}/Apache_Portable_Runtime_Utility_Library-LICENSE.txt" \
    && cp ./srclib/apr-util/NOTICE  "${LICENSES_DIR}/Apache_Portable_Runtime_Utility_Library-NOTICE.txt"

################################################################################
FROM $BASE_OS_IMAGE

ARG APACHE_HTTP_SERVER_INSTALL_PREFIX
ARG EXPAT_INSTALL_PREFIX
ARG LIBXML2_INSTALL_PREFIX
ARG LUA_INSTALL_PREFIX
ARG NGHTTP2_INSTALL_PREFIX
ARG OPENSSL_INSTALL_PREFIX
ARG PCRE2_INSTALL_PREFIX
ARG ZLIB_INSTALL_PREFIX
ARG LICENSES_DIR

COPY --from=apache-http-server-builder $APACHE_HTTP_SERVER_INSTALL_PREFIX $APACHE_HTTP_SERVER_INSTALL_PREFIX
COPY --from=apache-http-server-builder $EXPAT_INSTALL_PREFIX $EXPAT_INSTALL_PREFIX
COPY --from=apache-http-server-builder $LIBXML2_INSTALL_PREFIX $LIBXML2_INSTALL_PREFIX
COPY --from=apache-http-server-builder $LUA_INSTALL_PREFIX $LUA_INSTALL_PREFIX
COPY --from=apache-http-server-builder $NGHTTP2_INSTALL_PREFIX $NGHTTP2_INSTALL_PREFIX
COPY --from=apache-http-server-builder $OPENSSL_INSTALL_PREFIX $OPENSSL_INSTALL_PREFIX
COPY --from=apache-http-server-builder $PCRE2_INSTALL_PREFIX $PCRE2_INSTALL_PREFIX
COPY --from=apache-http-server-builder $ZLIB_INSTALL_PREFIX $ZLIB_INSTALL_PREFIX

COPY --from=apache-http-server-builder $LICENSES_DIR $LICENSES_DIR
COPY --from=expat-image $LICENSES_DIR $LICENSES_DIR
COPY --from=libxml2-image $LICENSES_DIR $LICENSES_DIR
COPY --from=lua-image $LICENSES_DIR $LICENSES_DIR
COPY --from=nghttp2-image $LICENSES_DIR $LICENSES_DIR
COPY --from=openssl-image $LICENSES_DIR $LICENSES_DIR
COPY --from=pcre2-image $LICENSES_DIR $LICENSES_DIR
COPY --from=zlib-image $LICENSES_DIR $LICENSES_DIR
COPY ./tools/show-licenses /usr/local/bin/show-licenses
RUN chmod 755 /usr/local/bin/show-licenses

ENV PATH="${APACHE_HTTP_SERVER_INSTALL_PREFIX}/bin:$PATH"
