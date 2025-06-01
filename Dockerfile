################################################################################
#
# Dockerfile
#
# © 2025 YOCKOW.
#     Licensed under MIT License.
#     See "LICENSE.txt" for more information.
#
################################################################################

##### Global values #####
ARG APACHE_HTTPD_INSTALL_PREFIX="/opt/httpd"
ARG LIBEXPAT_INSTALL_PREFIX="/opt/libexpat"
ARG LIBXML2_INSTALL_PREFIX="/opt/libxml2"
ARG LUA_INSTALL_PREFIX="/opt/lua"
ARG NGHTTP2_INSTALL_PREFIX="/opt/nghttp2"
ARG OPENSSL_INSTALL_PREFIX="/opt/openssl"
ARG PCRE2_INSTALL_PREFIX="/opt/pcre2"
ARG ZLIB_INSTALL_PREFIX="/opt/zlib"

ARG LICENSES_DIR="/licenses"

ARG SWIFT_VERSION="6.1.2"

##### Base image for building #####
FROM ubuntu:noble AS build-base
RUN apt update \
    && apt upgrade -y \
    && apt install -y \
        autoconf \
        automake \
        build-essential \
        clang \
        curl \
        gnupg2 \
        libcurl4-openssl-dev \
        libtool \
        m4 \
        perl \
        pkg-config \
        zsh


##### Lua #####
FROM build-base AS lua-builder

ARG LUA_VERSION="5.4.7"
ARG LUA_BUILD_WORKSPACE="/lua-workspace"
ARG LUA_INSTALL_PREFIX
ARG LICENSES_DIR
ENV LUA_BIN_URL="https://lua.org/ftp/lua-${LUA_VERSION}.tar.gz" \
    LUA_HASH="9fbf5e28ef86c69858f6d3d34eccc32e911c1a28b4120ff3e84aaa70cfbf1e30" \
    LUA_SOURCE_DIR="${LUA_BUILD_WORKSPACE}/lua" 

RUN mkdir "$LUA_BUILD_WORKSPACE" \
    && mkdir "$LUA_SOURCE_DIR"

WORKDIR $LUA_BUILD_WORKSPACE
RUN curl -sL "$LUA_BIN_URL" -o lua.tar.gz
RUN echo "$LUA_HASH lua.tar.gz" >lua.tar.gz.hash
RUN sha256sum --check lua.tar.gz.hash
RUN tar -xzf lua.tar.gz --directory "$LUA_SOURCE_DIR" --strip-components=1

WORKDIR $LUA_SOURCE_DIR
RUN make MYCFLAGS="-fPIC" CC=clang CXX=clang++ && make install INSTALL_TOP="$LUA_INSTALL_PREFIX"

COPY ./tools/extract-lua-license "${LUA_BUILD_WORKSPACE}/extract-lua-license"
RUN mkdir -p "$LICENSES_DIR" && "${LUA_BUILD_WORKSPACE}/extract-lua-license" ./doc/readme.html >"${LICENSES_DIR}/Lua.html"


##### PCRE2 #####
FROM build-base AS pcre2-builder

ARG PCRE2_VERSION="10.45"
ARG PCRE2_BUILD_WORKSPACE="/pcre2-workspace"
ARG PCRE2_INSTALL_PREFIX
ARG LICENSES_DIR
ENV PCRE2_BIN_URL="https://github.com/PCRE2Project/pcre2/releases/download/pcre2-${PCRE2_VERSION}/pcre2-${PCRE2_VERSION}.tar.gz" \
    PCRE2_SIG_URL="https://github.com/PCRE2Project/pcre2/releases/download/pcre2-${PCRE2_VERSION}/pcre2-${PCRE2_VERSION}.tar.gz.sig" \
    PCRE2_SOURCE_DIR="${PCRE2_BUILD_WORKSPACE}/pcre2" \
    GNUPGHOME="${PCRE2_BUILD_WORKSPACE}/.gpg" \
    CC=clang CXX=clang++

RUN mkdir "$PCRE2_BUILD_WORKSPACE" \
    && mkdir "$PCRE2_SOURCE_DIR" \
    && mkdir "$GNUPGHOME" \
    && chmod 600 "$GNUPGHOME"
RUN gpg --keyserver keyserver.ubuntu.com --recv-key 45F68D54BBE23FB3039B46E59766E084FB0F43D8 A95536204A3BB489715231282A98E77EB6F24CA8

WORKDIR $PCRE2_BUILD_WORKSPACE
RUN curl -sL "$PCRE2_BIN_URL" -o pcre2.tar.gz "$PCRE2_SIG_URL" -o pcre2.tar.gz.sig
RUN gpg --batch --verify pcre2.tar.gz.sig pcre2.tar.gz
RUN tar -xzf pcre2.tar.gz --directory "$PCRE2_SOURCE_DIR" --strip-components=1

WORKDIR $PCRE2_SOURCE_DIR
RUN ./configure \
        --prefix="$PCRE2_INSTALL_PREFIX" \
        --enable-shared \
        --enable-jit
RUN make && make install
RUN mkdir -p "$LICENSES_DIR" && cp ./LICENCE.md "${LICENSES_DIR}/PCRE2.md"


##### zlib #####
FROM build-base AS zlib-builder

ARG ZLIB_VERSION="1.3.1"
ARG ZLIB_BUILD_WORKSPACE="/zlib-workspace"
ARG ZLIB_INSTALL_PREFIX
ARG LICENSES_DIR
ENV ZLIB_BIN_URL="https://zlib.net/zlib-${ZLIB_VERSION}.tar.gz" \
    ZLIB_SIG_URL="https://zlib.net/zlib-${ZLIB_VERSION}.tar.gz.asc" \
    ZLIB_SOURCE_DIR="${ZLIB_BUILD_WORKSPACE}/zlib" \
    GNUPGHOME="${ZLIB_BUILD_WORKSPACE}/.gpg" \
    CC=clang CXX=clang++

RUN mkdir "$ZLIB_BUILD_WORKSPACE" \
    && mkdir "$ZLIB_SOURCE_DIR" \
    && mkdir "$GNUPGHOME" \
    && chmod 600 "$GNUPGHOME"
RUN curl -sL https://madler.net/madler/pgp.html | gpg --import

WORKDIR $ZLIB_BUILD_WORKSPACE
RUN curl -sL "$ZLIB_BIN_URL" -o zlib.tar.gz "$ZLIB_SIG_URL" -o zlib.tar.gz.asc
RUN gpg --batch --verify zlib.tar.gz.asc zlib.tar.gz
RUN tar -xzf zlib.tar.gz --directory "$ZLIB_SOURCE_DIR" --strip-components=1

WORKDIR $ZLIB_SOURCE_DIR
RUN ./configure --shared --prefix="$ZLIB_INSTALL_PREFIX"
RUN make && make install
RUN mkdir -p "$LICENSES_DIR" && cp ./LICENSE "${LICENSES_DIR}/zlib.txt"


##### libexpat #####
FROM build-base AS libexpat-builder

ARG LIBEXPAT_VERSION="2.7.1"
ARG LIBEXPAT_TAG="R_2_7_1"
ARG LIBEXPAT_BUILD_WORKSPACE="/libexpat-workspace"
ARG LIBEXPAT_INSTALL_PREFIX
ARG LICENSES_DIR
ENV LIBEXPAT_BIN_URL="https://github.com/libexpat/libexpat/releases/download/${LIBEXPAT_TAG}/expat-${LIBEXPAT_VERSION}.tar.gz" \
    LIBEXPAT_SIG_URL="https://github.com/libexpat/libexpat/releases/download/${LIBEXPAT_TAG}/expat-${LIBEXPAT_VERSION}.tar.gz.asc" \
    LIBEXPAT_SOURCE_DIR="${LIBEXPAT_BUILD_WORKSPACE}/libexpat" \
    GNUPGHOME="${LIBEXPAT_BUILD_WORKSPACE}/.gpg" \
    CC=clang CXX=clang++

RUN mkdir "$LIBEXPAT_BUILD_WORKSPACE" \
    && mkdir "$LIBEXPAT_SOURCE_DIR" \
    && mkdir "$GNUPGHOME" \
    && chmod 600 "$GNUPGHOME"
RUN gpg --keyserver keyserver.ubuntu.com --recv-key 1F9B0E909AF37285

WORKDIR $LIBEXPAT_BUILD_WORKSPACE
RUN curl -sL "$LIBEXPAT_BIN_URL" -o libexpat.tar.gz "$LIBEXPAT_SIG_URL" -o libexpat.tar.gz.asc
RUN gpg --batch --verify libexpat.tar.gz.asc libexpat.tar.gz
RUN tar -xzf libexpat.tar.gz --directory "$LIBEXPAT_SOURCE_DIR" --strip-components=1

WORKDIR $LIBEXPAT_SOURCE_DIR
RUN ./configure --prefix="$LIBEXPAT_INSTALL_PREFIX"
RUN make && make install
RUN mkdir -p "$LICENSES_DIR" && cp ./COPYING "${LICENSES_DIR}/Expat.txt"


##### libxml2 #####
FROM build-base AS libxml2-builder

ARG LIBXML2_VERSION="2.14.3"
ARG LIBXML2_BUILD_WORKSPACE="/libxml2-workspace"
ARG LIBXML2_INSTALL_PREFIX
ARG LICENSES_DIR
ENV LIBXML2_BIN_URL="https://gitlab.gnome.org/GNOME/libxml2/-/archive/v${LIBXML2_VERSION}/libxml2-v${LIBXML2_VERSION}.tar.gz" \
    LIBXML2_SOURCE_DIR="${LIBXML2_BUILD_WORKSPACE}/libxml2" \
    CC=clang CXX=clang++
# FIXME: No signature files?

RUN mkdir "$LIBXML2_BUILD_WORKSPACE" \
    && mkdir "$LIBXML2_SOURCE_DIR"

WORKDIR $LIBXML2_BUILD_WORKSPACE
RUN curl -sL "$LIBXML2_BIN_URL" -o libxml2.tar.gz
RUN tar -xzf libxml2.tar.gz --directory "$LIBXML2_SOURCE_DIR" --strip-components=1

WORKDIR $LIBXML2_SOURCE_DIR
RUN ./autogen.sh --prefix="$LIBXML2_INSTALL_PREFIX" --without-python \
    && ./configure --prefix="$LIBXML2_INSTALL_PREFIX" --without-python
RUN make && make install
RUN mkdir -p "$LICENSES_DIR" && cp ./Copyright "${LICENSES_DIR}/libxml2.txt"


##### OpenSSL #####
FROM build-base AS openssl-builder

ARG ZLIB_INSTALL_PREFIX
COPY --from=zlib-builder $ZLIB_INSTALL_PREFIX $ZLIB_INSTALL_PREFIX

ARG OPENSSL_VERSION="3.5.0"
ARG OPENSSL_BUILD_WORKSPACE="/openssl-workspace"
ARG OPENSSL_INSTALL_PREFIX
ARG LICENSES_DIR
ENV OPENSSL_BIN_URL="https://github.com/openssl/openssl/releases/download/openssl-${OPENSSL_VERSION}/openssl-${OPENSSL_VERSION}.tar.gz" \
    OPENSSL_SIG_URL="https://github.com/openssl/openssl/releases/download/openssl-${OPENSSL_VERSION}/openssl-${OPENSSL_VERSION}.tar.gz.asc" \
    OPENSSL_SOURCE_DIR="${OPENSSL_BUILD_WORKSPACE}/openssl" \
    GNUPGHOME="${OPENSSL_BUILD_WORKSPACE}/.gpg" \
    CC=clang CXX=clang++

RUN mkdir "$OPENSSL_BUILD_WORKSPACE" \
    && mkdir "$OPENSSL_SOURCE_DIR" \
    && mkdir "$GNUPGHOME" \
    && chmod 600 "$GNUPGHOME"
RUN curl -sL https://openssl-library.org/source/pubkeys.asc | gpg --import

WORKDIR $OPENSSL_BUILD_WORKSPACE
RUN curl -sL "$OPENSSL_BIN_URL" -o openssl.tar.gz "$OPENSSL_SIG_URL" -o openssl.tar.gz.asc
RUN gpg --batch --verify openssl.tar.gz.asc openssl.tar.gz
RUN tar -xzf openssl.tar.gz --directory "$OPENSSL_SOURCE_DIR" --strip-components=1

WORKDIR $OPENSSL_SOURCE_DIR
RUN perl ./Configure \
        --prefix="$OPENSSL_INSTALL_PREFIX" \
        --with-zlib-include="${ZLIB_INSTALL_PREFIX}/include" \
        shared zlib zlib-dynamic
RUN make && make install
RUN mkdir -p "${LICENSES_DIR}" && cp ./LICENSE.txt "${LICENSES_DIR}/OpenSSL.txt"


##### nghttp2 #####
FROM build-base AS nghttp2-builder

ARG OPENSSL_INSTALL_PREFIX
COPY --from=openssl-builder $OPENSSL_INSTALL_PREFIX $OPENSSL_INSTALL_PREFIX

ARG NGHTTP2_VERSION="1.65.0"
ARG NGHTTP2_BUILD_WORKSPACE="/nghttp2-workspace"
ARG NGHTTP2_INSTALL_PREFIX
ARG LICENSES_DIR
ENV NGHTTP2_BIN_URL="https://github.com/nghttp2/nghttp2/releases/download/v${NGHTTP2_VERSION}/nghttp2-${NGHTTP2_VERSION}.tar.gz" \
    NGHTTP2_SIG_URL="https://github.com/nghttp2/nghttp2/releases/download/v${NGHTTP2_VERSION}/nghttp2-${NGHTTP2_VERSION}.tar.gz.asc" \
    NGHTTP2_SOURCE_DIR="${NGHTTP2_BUILD_WORKSPACE}/nghttp2" \
    GNUPGHOME="${NGHTTP2_BUILD_WORKSPACE}/.gpg" \
    CC=clang CXX=clang++ \
    OPENSSL_CFLAGS="-I${OPENSSL_INSTALL_PREFIX}/include" OPENSSL_LIBS="-L${OPENSSL_INSTALL_PREFIX}/lib -lssl -lcrypto"

RUN mkdir "$NGHTTP2_BUILD_WORKSPACE" \
    && mkdir "$NGHTTP2_SOURCE_DIR" \
    && mkdir "$GNUPGHOME" \
    && chmod 600 "$GNUPGHOME"
RUN gpg --keyserver keyserver.ubuntu.com --recv-key 5339A2BE82E07DEC

WORKDIR $NGHTTP2_BUILD_WORKSPACE
RUN curl -sL "$NGHTTP2_BIN_URL" -o nghttp2.tar.gz "$NGHTTP2_SIG_URL" -o nghttp2.tar.gz.asc
RUN gpg --batch --verify nghttp2.tar.gz.asc nghttp2.tar.gz
RUN tar -xzf nghttp2.tar.gz --directory "$NGHTTP2_SOURCE_DIR" --strip-components=1

WORKDIR $NGHTTP2_SOURCE_DIR
RUN ./configure --prefix="$NGHTTP2_INSTALL_PREFIX" --enable-lib-only
RUN make && make install
RUN mkdir -p "${LICENSES_DIR}" && cp ./COPYING "${LICENSES_DIR}/nghttp2.txt"


##### httpd #####
FROM build-base AS httpd-builder

ARG LIBEXPAT_INSTALL_PREFIX
ARG LIBXML2_INSTALL_PREFIX
ARG LUA_INSTALL_PREFIX
ARG NGHTTP2_INSTALL_PREFIX
ARG OPENSSL_INSTALL_PREFIX
ARG PCRE2_INSTALL_PREFIX
ARG ZLIB_INSTALL_PREFIX
COPY --from=libexpat-builder $LIBEXPAT_INSTALL_PREFIX $LIBEXPAT_INSTALL_PREFIX
COPY --from=libxml2-builder $LIBXML2_INSTALL_PREFIX $LIBXML2_INSTALL_PREFIX
COPY --from=lua-builder $LUA_INSTALL_PREFIX $LUA_INSTALL_PREFIX
COPY --from=nghttp2-builder $NGHTTP2_INSTALL_PREFIX $NGHTTP2_INSTALL_PREFIX
COPY --from=openssl-builder $OPENSSL_INSTALL_PREFIX $OPENSSL_INSTALL_PREFIX
COPY --from=pcre2-builder $PCRE2_INSTALL_PREFIX $PCRE2_INSTALL_PREFIX
COPY --from=zlib-builder $ZLIB_INSTALL_PREFIX $ZLIB_INSTALL_PREFIX

ARG APACHE_HTTPD_VERSION="2.4.63"
ARG APACHE_APR_VERSION="1.7.6"
ARG APACHE_APRUTIL_VERSION="1.6.3"
ARG APACHE_WEB_ROOT="https://dlcdn.apache.org/"
ARG APACHE_HTTPD_KEYS_URL="https://downloads.apache.org/httpd/KEYS"
ARG APACHE_APR_KEYS_URL="https://downloads.apache.org/apr/KEYS"
ARG APACHE_BUILD_WORKSPACE="/apache-workspace"
ARG APACHE_HTTPD_INSTALL_PREFIX
ARG LICENSES_DIR
ENV APACHE_HTTPD_BIN_URL="${APACHE_WEB_ROOT}/httpd/httpd-${APACHE_HTTPD_VERSION}.tar.gz" \
    APACHE_HTTPD_SIG_URL="${APACHE_WEB_ROOT}/httpd/httpd-${APACHE_HTTPD_VERSION}.tar.gz.asc" \
    APACHE_APR_BIN_URL="${APACHE_WEB_ROOT}/apr/apr-${APACHE_APR_VERSION}.tar.gz" \
    APACHE_APR_SIG_URL="${APACHE_WEB_ROOT}/apr/apr-${APACHE_APR_VERSION}.tar.gz.asc" \
    APACHE_APRUTIL_BIN_URL="${APACHE_WEB_ROOT}/apr/apr-util-${APACHE_APRUTIL_VERSION}.tar.gz" \
    APACHE_APRUTIL_SIG_URL="${APACHE_WEB_ROOT}/apr/apr-util-${APACHE_APRUTIL_VERSION}.tar.gz.asc" \
    APACHE_HTTPD_SOURCE_DIR="${APACHE_BUILD_WORKSPACE}/httpd" \
    GNUPGHOME="${APACHE_BUILD_WORKSPACE}/.gpg" \
    PCRE_CONFIG="${PCRE2_INSTALL_PREFIX}/bin/pcre2-config" \
    CC=clang CXX=clang++

RUN mkdir "$APACHE_BUILD_WORKSPACE" \
    && mkdir "$APACHE_HTTPD_SOURCE_DIR" \
    && mkdir "$GNUPGHOME" \
    && chmod 600 "$GNUPGHOME"
RUN curl -sL "$APACHE_HTTPD_KEYS_URL" | gpg --import
RUN curl -sL "$APACHE_APR_KEYS_URL" | gpg --import

WORKDIR $APACHE_BUILD_WORKSPACE

RUN curl -sL "$APACHE_HTTPD_BIN_URL" -o httpd.tar.gz "$APACHE_HTTPD_SIG_URL" -o httpd.tar.gz.asc
RUN gpg --batch --verify httpd.tar.gz.asc httpd.tar.gz
RUN tar -xzf httpd.tar.gz --directory "$APACHE_HTTPD_SOURCE_DIR" --strip-components=1

RUN curl -sL "$APACHE_APR_BIN_URL" -o apr.tar.gz "$APACHE_APR_SIG_URL" -o apr.tar.gz.asc
RUN gpg --batch --verify apr.tar.gz.asc apr.tar.gz
RUN mkdir -p "${APACHE_HTTPD_SOURCE_DIR}/srclib/apr"
RUN tar -xzf apr.tar.gz --directory "${APACHE_HTTPD_SOURCE_DIR}/srclib/apr" --strip-components=1

RUN curl -sL "$APACHE_APRUTIL_BIN_URL" -o apr-util.tar.gz "$APACHE_APRUTIL_SIG_URL" -o apr-util.tar.gz.asc
RUN gpg --batch --verify apr-util.tar.gz.asc apr-util.tar.gz
RUN mkdir -p "${APACHE_HTTPD_SOURCE_DIR}/srclib/apr-util"
RUN tar -xzf apr-util.tar.gz --directory "${APACHE_HTTPD_SOURCE_DIR}/srclib/apr-util" --strip-components=1

WORKDIR $APACHE_HTTPD_SOURCE_DIR
RUN ./configure \
        --prefix="$APACHE_HTTPD_INSTALL_PREFIX" \
        --with-included-apr --with-expat="$LIBEXPAT_INSTALL_PREFIX" \
        --enable-mpms-shared=all \
        --enable-mods-shared=reallyall \
        --enable-deflate --with-z="$ZLIB_INSTALL_PREFIX" \
        --enable-lua --with-lua="$LUA_INSTALL_PREFIX" \
        --enable-proxy-html --enable-xml2enc --with-libxml2="$LIBXML2_INSTALL_PREFIX" \
        --enable-ssl --with-ssl="$OPENSSL_INSTALL_PREFIX" \
        --enable-http2 --with-nghttp2="$NGHTTP2_INSTALL_PREFIX" \
        --with-pcre="$PCRE2_INSTALL_PREFIX"
RUN make && make install
RUN mkdir -p "${LICENSES_DIR}" \
    && cp ./LICENSE "${LICENSES_DIR}/Apache_HTTP_Server-LICENSE.txt" \
    && cp ./NOTICE  "${LICENSES_DIR}/Apache_HTTP_Server-NOTICE.txt" \
    && cp ./srclib/apr/LICENSE "${LICENSES_DIR}/Apache_Portable_Runtime-LICENSE.txt" \
    && cp ./srclib/apr/NOTICE  "${LICENSES_DIR}/Apache_Portable_Runtime-NOTICE.txt" \
    && cp ./srclib/apr-util/LICENSE "${LICENSES_DIR}/Apache_Portable_Runtime_Utility_Library-LICENSE.txt" \
    && cp ./srclib/apr-util/NOTICE  "${LICENSES_DIR}/Apache_Portable_Runtime_Utility_Library-NOTICE.txt"



##### Swift license #####
FROM build-base AS swift-license-fetcher

ARG LICENSES_DIR
ARG SWIFT_VERSION
RUN mkdir -p "${LICENSES_DIR}" \
    && curl -sL "https://raw.githubusercontent.com/swiftlang/swift/refs/tags/swift-${SWIFT_VERSION}-RELEASE/LICENSE.txt" -o "${LICENSES_DIR}/Swift.txt"

##### Swift! #####
FROM swift:${SWIFT_VERSION}-noble-slim

ARG APACHE_HTTPD_INSTALL_PREFIX
ARG LIBEXPAT_INSTALL_PREFIX
ARG LIBXML2_INSTALL_PREFIX
ARG LUA_INSTALL_PREFIX
ARG NGHTTP2_INSTALL_PREFIX
ARG OPENSSL_INSTALL_PREFIX
ARG PCRE2_INSTALL_PREFIX
ARG ZLIB_INSTALL_PREFIX

ARG LICENSES_DIR

COPY --from=httpd-builder $APACHE_HTTPD_INSTALL_PREFIX $APACHE_HTTPD_INSTALL_PREFIX
COPY --from=httpd-builder $LICENSES_DIR $LICENSES_DIR

COPY --from=libexpat-builder $LIBEXPAT_INSTALL_PREFIX $LIBEXPAT_INSTALL_PREFIX
COPY --from=libexpat-builder $LICENSES_DIR $LICENSES_DIR

COPY --from=libxml2-builder $LIBXML2_INSTALL_PREFIX $LIBXML2_INSTALL_PREFIX
COPY --from=libxml2-builder $LICENSES_DIR $LICENSES_DIR

COPY --from=lua-builder $LUA_INSTALL_PREFIX $LUA_INSTALL_PREFIX
COPY --from=lua-builder $LICENSES_DIR $LICENSES_DIR

COPY --from=nghttp2-builder $NGHTTP2_INSTALL_PREFIX $NGHTTP2_INSTALL_PREFIX
COPY --from=nghttp2-builder $LICENSES_DIR $LICENSES_DIR

COPY --from=openssl-builder $OPENSSL_INSTALL_PREFIX $OPENSSL_INSTALL_PREFIX
COPY --from=openssl-builder $LICENSES_DIR $LICENSES_DIR

COPY --from=pcre2-builder $PCRE2_INSTALL_PREFIX $PCRE2_INSTALL_PREFIX
COPY --from=pcre2-builder $LICENSES_DIR $LICENSES_DIR

COPY --from=swift-license-fetcher $LICENSES_DIR $LICENSES_DIR

COPY --from=zlib-builder $ZLIB_INSTALL_PREFIX $ZLIB_INSTALL_PREFIX
COPY --from=zlib-builder $LICENSES_DIR $LICENSES_DIR

COPY ./tools/show-licenses /usr/local/bin/show-licenses
RUN chmod 755 /usr/local/bin/show-licenses