################################################################################
#
# images/deps/zlib/Dockerfile
#
# © 2025 YOCKOW.
#     Licensed under MIT License.
#     See "LICENSE.txt" for more information.
#
################################################################################

# Configurable arguments
ARG ZLIB_VERSION="1.3.1"
ARG PCRE2_INSTALL_PREFIX="/opt/zlib"
ARG LICENSES_DIR="/licenses"

################################################################################
FROM ubuntu:noble AS zlib-builder
ARG ZLIB_VERSION
ARG ZLIB_INSTALL_PREFIX
ARG LICENSES_DIR
ENV ZLIB_WORKSPACE="/workspace"
ENV ZLIB_BIN_URL="https://zlib.net/zlib-${ZLIB_VERSION}.tar.gz"
ENV ZLIB_SIG_URL="https://zlib.net/zlib-${ZLIB_VERSION}.tar.gz.asc"
ENV ZLIB_BIN_LOCAL_BASENAME="zlib.tar.gz"
ENV ZLIB_SIG_LOCAL_BASENAME="zlib.tar.gz.asc"
ENV ZLIB_SOURCE_DIR="${ZLIB_WORKSPACE}/zlib"
ENV GNUPGHOME="${ZLIB_WORKSPACE}/.gpg"

RUN apt update \
    && apt upgrade -y \
    && apt install -y \
        clang \
        cmake \
        gnupg2 \
        ninja-build \
        wget
RUN mkdir -p "${ZLIB_WORKSPACE}" "${ZLIB_SOURCE_DIR}" "${GNUPGHOME}" \
    && chmod 600 "${GNUPGHOME}"
RUN wget -q -O- 'https://madler.net/madler/pgp.html' | gpg --import

RUN wget -q -O "${ZLIB_BIN_LOCAL_BASENAME}" "${ZLIB_BIN_URL}" \
    && wget -q -O "${ZLIB_SIG_LOCAL_BASENAME}" "${ZLIB_SIG_URL}"
RUN gpg --batch --verify "${ZLIB_SIG_LOCAL_BASENAME}" "${ZLIB_BIN_LOCAL_BASENAME}"
RUN tar -xzf "${ZLIB_BIN_LOCAL_BASENAME}" --directory "${ZLIB_SOURCE_DIR}" --strip-components=1

WORKDIR $ZLIB_SOURCE_DIR
RUN cmake .\
        -DCMAKE_INSTALL_PREFIX:PATH="${ZLIB_INSTALL_PREFIX}" \
        -DCMAKE_C_COMPILER:STRING=clang \
        -DCMAKE_CXX_COMPILER:STRING=clang++ \
        -DCMAKE_BUILD_TYPE:STRING=Release \
        -G "Ninja"
RUN ninja && ninja install
RUN mkdir -p "$LICENSES_DIR" && cp ./LICENSE "${LICENSES_DIR}/zlib.txt"

################################################################################
FROM ubuntu:noble
ARG ZLIB_INSTALL_PREFIX
ARG LICENSES_DIR
COPY --from=zlib-builder $ZLIB_INSTALL_PREFIX $ZLIB_INSTALL_PREFIX
COPY --from=zlib-builder $LICENSES_DIR $LICENSES_DIR
COPY ./tools/show-licenses /usr/local/bin/show-licenses
RUN chmod 755 /usr/local/bin/show-licenses
