################################################################################
#
# images/deps/PCRE2/Dockerfile
#
# © 2025 YOCKOW.
#     Licensed under MIT License.
#     See "LICENSE.txt" for more information.
#
################################################################################

# Configurable arguments
ARG BASE_UBUNTU_VERSION="noble"
ARG BASE_OS_IMAGE="ubuntu:${BASE_UBUNTU_VERSION}"
ARG PCRE2_VERSION="10.46"
ARG PCRE2_INSTALL_PREFIX="/opt/PCRE2"
ARG LICENSES_DIR="/licenses"

################################################################################
FROM $BASE_OS_IMAGE AS pcre2-builder
ARG PCRE2_VERSION
ARG PCRE2_INSTALL_PREFIX
ARG LICENSES_DIR
ENV PCRE2_WORKSPACE="/workspace"
ENV PCRE2_SOURCE_DIR="${PCRE2_WORKSPACE}/PCRE2"
ENV PCRE2_BIN_URL="https://github.com/PCRE2Project/pcre2/releases/download/pcre2-${PCRE2_VERSION}/pcre2-${PCRE2_VERSION}.tar.gz" 
ENV PCRE2_SIG_URL="https://github.com/PCRE2Project/pcre2/releases/download/pcre2-${PCRE2_VERSION}/pcre2-${PCRE2_VERSION}.tar.gz.sig"
ENV PCRE2_BIN_LOCAL_BASENAME="PCRE2.tar.gz"
ENV PCRE2_SIG_LOCAL_BASENAME="PCRE2.tar.gz.sig"
ENV GNUPGHOME="${PCRE2_WORKSPACE}/.gpg"

RUN apt update \
    && apt upgrade -y \
    && apt install -y \
        clang \
        gnupg2 \
        make \
        wget

RUN mkdir -p "${PCRE2_WORKSPACE}" "${PCRE2_SOURCE_DIR}" "${GNUPGHOME}" \
    && chmod 600 "${GNUPGHOME}"
RUN gpg --keyserver keyserver.ubuntu.com --recv-key 45F68D54BBE23FB3039B46E59766E084FB0F43D8 A95536204A3BB489715231282A98E77EB6F24CA8

WORKDIR $PCRE2_WORKSPACE
RUN wget -q -O "${PCRE2_BIN_LOCAL_BASENAME}" "${PCRE2_BIN_URL}" \
    && wget -q -O "${PCRE2_SIG_LOCAL_BASENAME}" "${PCRE2_SIG_URL}"
RUN gpg --batch --verify "${PCRE2_SIG_LOCAL_BASENAME}" "${PCRE2_BIN_LOCAL_BASENAME}"
RUN tar -xzf "${PCRE2_BIN_LOCAL_BASENAME}" --directory "${PCRE2_SOURCE_DIR}" --strip-components=1

WORKDIR $PCRE2_SOURCE_DIR
RUN ./configure \
        --prefix="$PCRE2_INSTALL_PREFIX" \
        --enable-shared \
        --enable-jit \
        CC=clang CXX=clang++
RUN make && make install
RUN mkdir -p "$LICENSES_DIR" && cp ./LICENCE.md "${LICENSES_DIR}/PCRE2.md"

################################################################################
FROM $BASE_OS_IMAGE
ARG PCRE2_INSTALL_PREFIX
ARG LICENSES_DIR
COPY --from=pcre2-builder $PCRE2_INSTALL_PREFIX $PCRE2_INSTALL_PREFIX
COPY --from=pcre2-builder $LICENSES_DIR $LICENSES_DIR
COPY ./tools/show-licenses /usr/local/bin/show-licenses
RUN chmod 755 /usr/local/bin/show-licenses
