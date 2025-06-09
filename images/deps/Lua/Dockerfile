################################################################################
#
# images/deps/Lua/Dockerfile
#
# © 2025 YOCKOW.
#     Licensed under MIT License.
#     See "LICENSE.txt" for more information.
#
################################################################################

# Configurable arguments
ARG LUA_VERSION="5.4.8"
ARG LUA_HASH="4f18ddae154e793e46eeab727c59ef1c0c0c2b744e7b94219710d76f530629ae"
ARG LUA_INSTALL_PREFIX="/opt/Lua"
ARG LICENSES_DIR="/licenses"

################################################################################
FROM ubuntu:noble AS lua-builder
ARG LUA_VERSION
ARG LUA_HASH
ARG LUA_INSTALL_PREFIX
ARG LICENSES_DIR
ENV LUA_WORKSPACE="/workspace"
ENV LUA_SOURCE_DIR="${LUA_WORKSPACE}/Lua"
ENV LUA_BIN_URL="https://lua.org/ftp/lua-${LUA_VERSION}.tar.gz"
ENV LUA_BIN_LOCAL_BASENAME="Lua.tar.gz"
ENV LUA_HASH_LOCAL_BASENAME="Lua.tar.gz.hash"

RUN apt update \
    && apt upgrade -y \
    && apt install -y \
        autoconf \
        automake \
        build-essential \
        clang \
        wget \
        zsh
RUN mkdir -p "$LUA_SOURCE_DIR"

WORKDIR $LUA_WORKSPACE
RUN wget -q -O "$LUA_BIN_LOCAL_BASENAME" "$LUA_BIN_URL"
RUN echo "${LUA_HASH} ${LUA_BIN_LOCAL_BASENAME}" >"$LUA_HASH_LOCAL_BASENAME"
RUN sha256sum --check "$LUA_HASH_LOCAL_BASENAME"
RUN tar -xzf "${LUA_BIN_LOCAL_BASENAME}" --directory "${LUA_SOURCE_DIR}" --strip-components=1

WORKDIR $LUA_SOURCE_DIR
RUN make MYCFLAGS="-fPIC" CC=clang CXX=clang++ && make install INSTALL_TOP="$LUA_INSTALL_PREFIX"
COPY ./tools/extract-lua-license "${LUA_WORKSPACE}/extract-lua-license"
RUN mkdir -p "$LICENSES_DIR" \
    && "${LUA_WORKSPACE}/extract-lua-license" ./doc/readme.html >"${LICENSES_DIR}/Lua.html"

################################################################################
FROM ubuntu:noble
ARG LUA_INSTALL_PREFIX
ARG LICENSES_DIR
COPY --from=lua-builder $LUA_INSTALL_PREFIX $LUA_INSTALL_PREFIX
COPY --from=lua-builder $LICENSES_DIR $LICENSES_DIR
COPY ./tools/show-licenses /usr/local/bin/show-licenses
RUN chmod 755 /usr/local/bin/show-licenses
