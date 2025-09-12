################################################################################
#
# images/deps/nghttp2/Dockerfile
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
ARG NGHTTP2_VERSION="1.67.0"
ARG NGHTTP2_INSTALL_PREFIX="/opt/nghttp2"
ARG LICENSES_DIR="/licenses"
ARG OPENSSL_VERSION="3.5.2"
ARG OPENSSL_IMAGE="ghcr.io/yockow/swift-de-cgi-deps:OpenSSL_${OPENSSL_VERSION}-${BASE_OS_LABEL}"
ARG OPENSSL_INSTALL_PREFIX="/opt/OpenSSL"
ARG ZLIB_VERSION="1.3.1"
ARG ZLIB_IMAGE="ghcr.io/yockow/swift-de-cgi-deps:zlib_${ZLIB_VERSION}-${BASE_OS_LABEL}"
ARG ZLIB_INSTALL_PREFIX="/opt/zlib"

################################################################################
FROM $OPENSSL_IMAGE AS openssl-image

################################################################################
FROM $ZLIB_IMAGE AS zlib-image

################################################################################
FROM $BASE_OS_IMAGE AS nghttp2-builder

ARG NGHTTP2_VERSION
ARG NGHTTP2_INSTALL_PREFIX
ARG LICENSES_DIR
ARG OPENSSL_INSTALL_PREFIX
ARG ZLIB_INSTALL_PREFIX
ENV NGHTTP2_WORKSPACE="/workspace"
ENV NGHTTP2_BIN_URL="https://github.com/nghttp2/nghttp2/releases/download/v${NGHTTP2_VERSION}/nghttp2-${NGHTTP2_VERSION}.tar.gz" \
    NGHTTP2_SIG_URL="https://github.com/nghttp2/nghttp2/releases/download/v${NGHTTP2_VERSION}/nghttp2-${NGHTTP2_VERSION}.tar.gz.asc"
ENV NGHTTP2_BIN_LOCAL_BASENAME="nghttp2.tar.gz" \
    NGHTTP2_SIG_LOCAL_BASENAME="nghttp2.tar.gz.asc"
ENV NGHTTP2_SOURCE_DIR="${NGHTTP2_WORKSPACE}/nghttp2"
ENV GNUPGHOME="${NGHTTP2_WORKSPACE}/.gpg"

RUN apt update \
    && apt upgrade -y \
    && apt install -y \
        clang \
        cmake \
        gnupg2 \
        ninja-build \
        wget

RUN mkdir -p "$NGHTTP2_WORKSPACE" "$NGHTTP2_SOURCE_DIR" "$GNUPGHOME" \
    && chmod 600 "$GNUPGHOME"
RUN gpg --keyserver keyserver.ubuntu.com --recv-key 5339A2BE82E07DEC

WORKDIR $NGHTTP2_WORKSPACE
RUN wget -q -O "${NGHTTP2_BIN_LOCAL_BASENAME}" "${NGHTTP2_BIN_URL}" \
    && wget -q -O "${NGHTTP2_SIG_LOCAL_BASENAME}" "$NGHTTP2_SIG_URL"
RUN gpg --batch --verify "${NGHTTP2_SIG_LOCAL_BASENAME}" "${NGHTTP2_BIN_LOCAL_BASENAME}" \
    && tar -xzf "${NGHTTP2_BIN_LOCAL_BASENAME}" --directory "$NGHTTP2_SOURCE_DIR" --strip-components=1

COPY --from=openssl-image "${OPENSSL_INSTALL_PREFIX}" "${OPENSSL_INSTALL_PREFIX}"
COPY --from=zlib-image "${ZLIB_INSTALL_PREFIX}" "${ZLIB_INSTALL_PREFIX}"

WORKDIR $NGHTTP2_SOURCE_DIR
RUN cmake . \
        -DCMAKE_INSTALL_PREFIX:PATH="${NGHTTP2_INSTALL_PREFIX}" \
        -DCMAKE_INSTALL_RPATH:STRING="${OPENSSL_INSTALL_PREFIX}/lib;${ZLIB_INSTALL_PREFIX}/lib;${NGHTTP2_INSTALL_PREFIX}/lib" \
        -DCMAKE_C_COMPILER:STRING=clang \
        -DCMAKE_CXX_COMPILER:STRING=clang++ \
        -DCMAKE_BUILD_TYPE:STRING=Release \
        -G "Ninja" \
        -DENABLE_LIB_ONLY:BOOL=ON \
        -DOPENSSL_ROOT_DIR:STRING="${OPENSSL_INSTALL_PREFIX}" \
        -DOPENSSL_CFLAGS="-I${OPENSSL_INSTALL_PREFIX}/include" \
        -DOPENSSL_LIBS="-L${OPENSSL_INSTALL_PREFIX}/lib -lssl -lcrypto"

RUN ninja && ninja install
RUN mkdir -p "${LICENSES_DIR}" && cp ./COPYING "${LICENSES_DIR}/nghttp2.txt"

################################################################################
FROM $BASE_OS_IMAGE
ARG NGHTTP2_INSTALL_PREFIX
ARG OPENSSL_INSTALL_PREFIX
ARG ZLIB_INSTALL_PREFIX
ARG LICENSES_DIR
COPY --from=nghttp2-builder $NGHTTP2_INSTALL_PREFIX $NGHTTP2_INSTALL_PREFIX
COPY --from=nghttp2-builder $OPENSSL_INSTALL_PREFIX $OPENSSL_INSTALL_PREFIX
COPY --from=nghttp2-builder $ZLIB_INSTALL_PREFIX $ZLIB_INSTALL_PREFIX
COPY --from=nghttp2-builder $LICENSES_DIR $LICENSES_DIR
COPY --from=openssl-image $LICENSES_DIR $LICENSES_DIR
COPY --from=zlib-image $LICENSES_DIR $LICENSES_DIR
COPY ./tools/show-licenses /usr/local/bin/show-licenses
RUN chmod 755 /usr/local/bin/show-licenses
