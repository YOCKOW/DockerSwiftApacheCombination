################################################################################
#
# images/deps/libxml2/Dockerfile
#
# © 2025 YOCKOW.
#     Licensed under MIT License.
#     See "LICENSE.txt" for more information.
#
################################################################################

# Configurable arguments
ARG LIBXML2_VERSION="2.14.3"
ARG LIBXML2_INSTALL_PREFIX="/opt/libxml2"
ARG LICENSES_DIR="/licenses"
ARG ZLIB_VERSION="1.3.1"
ARG ZLIB_IMAGE="ghcr.io/yockow/swift-de-cgi-deps:zlib-${ZLIB_VERSION}"
ARG ZLIB_INSTALL_PREFIX="/opt/zlib"

################################################################################
FROM $ZLIB_IMAGE AS zlib-image

################################################################################
FROM ubuntu:noble AS libxml2-builder
ARG LIBXML2_VERSION
ARG LIBXML2_INSTALL_PREFIX
ARG LICENSES_DIR
ARG ZLIB_IMAGE
ARG ZLIB_INSTALL_PREFIX
ENV LIBXML2_WORKSPACE="/workspace"
ENV LIBXML2_BIN_URL="https://gitlab.gnome.org/GNOME/libxml2/-/archive/v${LIBXML2_VERSION}/libxml2-v${LIBXML2_VERSION}.tar.gz"
# FIXME: No signature files?
ENV LIBXML2_BIN_LOCAL_BASENAME="libxml2.tar.gz"
ENV LIBXML2_SOURCE_DIR="${LIBXML2_WORKSPACE}/libxml2"

RUN apt update \
    && apt upgrade -y \
    && apt install -y \
        autoconf \
        automake \
        build-essential \
        clang \
        wget
RUN mkdir -p "$LIBXML2_WORKSPACE" "$LIBXML2_SOURCE_DIR"
COPY --from=zlib-image $ZLIB_INSTALL_PREFIX $ZLIB_INSTALL_PREFIX

WORKDIR $LIBXML2_WORKSPACE
RUN wget -q -O "$LIBXML2_BIN_LOCAL_BASENAME" "$LIBXML2_BIN_URL"
RUN tar -xzf "${LIBXML2_BIN_LOCAL_BASENAME}" --directory "${LIBXML2_SOURCE_DIR}" --strip-components=1

WORKDIR $LIBXML2_SOURCE_DIR
RUN ./autogen.sh \
        --prefix="$LIBXML2_INSTALL_PREFIX" \
        --without-python \
        --with-zlib="$ZLIB_INSTALL_PREFIX" \
    && CC=clang CXX=clang++ CFLAGS=-O2 ./configure \
        --prefix="$LIBXML2_INSTALL_PREFIX" \
        --without-python \
        --with-zlib="$ZLIB_INSTALL_PREFIX"
RUN make && make install
RUN mkdir -p "$LICENSES_DIR" && cp ./Copyright "${LICENSES_DIR}/libxml2.txt"

################################################################################
FROM ubuntu:noble
ARG LIBXML2_INSTALL_PREFIX
ARG ZLIB_INSTALL_PREFIX
ARG LICENSES_DIR
COPY --from=libxml2-builder $LIBXML2_INSTALL_PREFIX $LIBXML2_INSTALL_PREFIX
COPY --from=libxml2-builder $ZLIB_INSTALL_PREFIX $ZLIB_INSTALL_PREFIX
COPY --from=libxml2-builder $LICENSES_DIR $LICENSES_DIR
COPY --from=zlib-image $LICENSES_DIR $LICENSES_DIR
COPY ./tools/show-licenses /usr/local/bin/show-licenses
RUN chmod 755 /usr/local/bin/show-licenses
