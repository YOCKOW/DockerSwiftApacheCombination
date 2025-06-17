################################################################################
#
# images/deps/OpenSSL/Dockerfile
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
ARG OPENSSL_VERSION="3.5.0"
ARG OPENSSL_INSTALL_PREFIX="/opt/OpenSSL"
ARG LICENSES_DIR="/licenses"
ARG ZLIB_VERSION="1.3.1"
ARG ZLIB_IMAGE="ghcr.io/yockow/swift-de-cgi-deps:zlib_${ZLIB_VERSION}-${BASE_OS_LABEL}"
ARG ZLIB_INSTALL_PREFIX="/opt/zlib"

################################################################################
FROM $ZLIB_IMAGE AS zlib-image

################################################################################
FROM $BASE_OS_IMAGE AS openssl-builder
ARG OPENSSL_VERSION
ARG OPENSSL_INSTALL_PREFIX
ARG LICENSES_DIR
ARG ZLIB_INSTALL_PREFIX
ENV OPENSSL_WORKSPACE="/workspace"
ENV OPENSSL_BIN_URL="https://github.com/openssl/openssl/releases/download/openssl-${OPENSSL_VERSION}/openssl-${OPENSSL_VERSION}.tar.gz" \
    OPENSSL_SIG_URL="https://github.com/openssl/openssl/releases/download/openssl-${OPENSSL_VERSION}/openssl-${OPENSSL_VERSION}.tar.gz.asc"
ENV OPENSSL_BIN_LOCAL_BASENAME="openssl.tar.gz" \
    OPENSSL_SIG_LOCAL_BASENAME="openssl.tar.gz.asc"
ENV OPENSSL_SOURCE_DIR="${OPENSSL_WORKSPACE}/openssl"
ENV GNUPGHOME="${OPENSSL_WORKSPACE}/.gpg"

RUN apt update \
    && apt upgrade -y \
    && apt install -y \
        autoconf \
        automake \
        build-essential \
        clang \
        perl \
        wget
RUN mkdir -p "${OPENSSL_WORKSPACE}" "${OPENSSL_SOURCE_DIR}" "${GNUPGHOME}" \
    && chmod "${GNUPGHOME}"
RUN wget -q -O- 'https://openssl-library.org/source/pubkeys.asc' | gpg --import

COPY --from=zlib-image "${ZLIB_INSTALL_PREFIX}" "${ZLIB_INSTALL_PREFIX}"

WORKDIR $OPENSSL_WORKSPACE
RUN wget -q -O "${OPENSSL_BIN_LOCAL_BASENAME}" "${OPENSSL_BIN_URL}" \
    && wget -q -O "${OPENSSL_SIG_LOCAL_BASENAME}" "${OPENSSL_SIG_URL}"
RUN gpg --batch --verify "${OPENSSL_SIG_LOCAL_BASENAME}" "${OPENSSL_BIN_LOCAL_BASENAME}" \
    && tar -xzf "${OPENSSL_BIN_LOCAL_BASENAME}" --directory "${OPENSSL_SOURCE_DIR}" --strip-components=1

WORKDIR $OPENSSL_SOURCE_DIR
RUN perl ./Configure \
        --prefix="$OPENSSL_INSTALL_PREFIX" \
        --with-zlib-include="${ZLIB_INSTALL_PREFIX}/include" \
        shared zlib zlib-dynamic
RUN make && make install
RUN mkdir -p "${LICENSES_DIR}" && cp ./LICENSE.txt "${LICENSES_DIR}/OpenSSL.txt"

################################################################################
FROM $BASE_OS_IMAGE
ARG OPENSSL_INSTALL_PREFIX
ARG ZLIB_INSTALL_PREFIX
ARG LICENSES_DIR
COPY --from=openssl-builder $OPENSSL_INSTALL_PREFIX $OPENSSL_INSTALL_PREFIX
COPY --from=openssl-builder $ZLIB_INSTALL_PREFIX $ZLIB_INSTALL_PREFIX
COPY --from=openssl-builder $LICENSES_DIR $LICENSES_DIR
COPY --from=zlib-image $LICENSES_DIR $LICENSES_DIR
COPY ./tools/show-licenses /usr/local/bin/show-licenses
RUN chmod 755 /usr/local/bin/show-licenses
