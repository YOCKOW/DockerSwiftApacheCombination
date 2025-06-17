################################################################################
#
# images/deps/Expat/Dockerfile
#
# © 2025 YOCKOW.
#     Licensed under MIT License.
#     See "LICENSE.txt" for more information.
#
################################################################################

# Configurable arguments
ARG BASE_UBUNTU_VERSION="noble"
ARG BASE_OS_IMAGE="ubuntu:${BASE_UBUNTU_VERSION}"
ARG EXPAT_VERSION="2.7.1"
ARG EXPAT_INSTALL_PREFIX="/opt/Expat"
ARG LICENSES_DIR="/licenses"

################################################################################
FROM $BASE_OS_IMAGE AS expat-builder
ARG EXPAT_VERSION
ARG EXPAT_INSTALL_PREFIX
ARG LICENSES_DIR
ENV EXPAT_WORKSPACE="/workspace"
ENV EXPAT_SOURCE_DIR="${EXPAT_WORKSPACE}/Expat"
ENV GNUPGHOME="${EXPAT_WORKSPACE}/.gpg"
ENV EXPAT_BIN_LOCAL_BASENAME="Expat.tar.gz"
ENV EXPAT_SIG_LOCAL_BASENAME="Expat.tar.gz.asc"

RUN apt update \
    && apt upgrade -y \
    && apt install -y \
        clang \
        cmake \
        gnupg2 \
        ninja-build \
        wget

RUN mkdir -p "$EXPAT_WORKSPACE" "$EXPAT_SOURCE_DIR" "$GNUPGHOME" \
    && chmod 600 "$GNUPGHOME"
RUN gpg --keyserver keyserver.ubuntu.com --recv-key 1F9B0E909AF37285

WORKDIR $EXPAT_WORKSPACE
RUN wget -q -O "${EXPAT_BIN_LOCAL_BASENAME}" "https://github.com/libexpat/libexpat/releases/download/R_$(echo "$EXPAT_VERSION" | sed 's/\./_/g')/expat-${EXPAT_VERSION}.tar.gz" \
    && wget -q -O "${EXPAT_SIG_LOCAL_BASENAME}" "https://github.com/libexpat/libexpat/releases/download/R_$(echo "$EXPAT_VERSION" | sed 's/\./_/g')/expat-${EXPAT_VERSION}.tar.gz.asc"
RUN gpg --batch --verify "$EXPAT_SIG_LOCAL_BASENAME" "${EXPAT_BIN_LOCAL_BASENAME}"
RUN tar -xzf "${EXPAT_BIN_LOCAL_BASENAME}" --directory "${EXPAT_SOURCE_DIR}" --strip-components=1

WORKDIR $EXPAT_SOURCE_DIR
RUN cmake .\
        -DCMAKE_INSTALL_PREFIX:PATH="${EXPAT_INSTALL_PREFIX}" \
        -DCMAKE_C_COMPILER:STRING=clang \
        -DCMAKE_CXX_COMPILER:STRING=clang++ \
        -DCMAKE_BUILD_TYPE:STRING=Release \
        -G "Ninja"
RUN ninja && ninja install
RUN mkdir -p "$LICENSES_DIR" && cp ./COPYING "${LICENSES_DIR}/Expat.txt"

################################################################################
FROM $BASE_OS_IMAGE
ARG EXPAT_INSTALL_PREFIX
ARG LICENSES_DIR
COPY --from=expat-builder $EXPAT_INSTALL_PREFIX $EXPAT_INSTALL_PREFIX
COPY --from=expat-builder $LICENSES_DIR $LICENSES_DIR
COPY ./tools/show-licenses /usr/local/bin/show-licenses
RUN chmod 755 /usr/local/bin/show-licenses
