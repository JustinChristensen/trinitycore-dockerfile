FROM debian:buster-slim

LABEL \
maintainer="justin@promise.io" \
version="1.0.0"

ARG TRINITYCORE_VERSION="3.3.5"
ARG TRINITYCORE_USER_HOME="/root"
ARG TRINITYCORE_SOURCE_DIR="${TRINITYCORE_USER_HOME}/TrinityCore"
ARG TRINITYCORE_BUILD_DIR="${TRINITYCORE_SOURCE_DIR}/build"
ARG TRINITYCORE_INSTALL_PREFIX="/usr/local"
ARG CMAKE_FLAGS="-DCMAKE_INSTALL_PREFIX=${TRINITYCORE_INSTALL_PREFIX}"

ENV TRINITYCORE_VERSION="${TRINITYCORE_VERSION}"

# install trinitycore dependencies
RUN \
apt-get update && \
apt-get install -y \
    curl \
    clang \
    cmake \
    libmariadb-dev-compat \
    libssl-dev \
    libbz2-dev \
    libreadline-dev \
    libncurses-dev \
    libboost-all-dev \
    make \
    mariadb-client \
    p7zip

WORKDIR ${TRINITYCORE_USER_HOME}

# pull down trinitycore
RUN \
echo "Pulling down version ${TRINITYCORE_VERSION} of TrinityCore..." && \
curl -o TrinityCore.tar.gz -sL "https://github.com/TrinityCore/TrinityCore/tarball/${TRINITYCORE_VERSION}" && \
mkdir -p "${TRINITYCORE_SOURCE_DIR}" && tar -xvzf TrinityCore.tar.gz -C "${TRINITYCORE_SOURCE_DIR}" --strip-components=1

# add the cmake wrapper
ADD cmake.sh "${TRINITYCORE_USER_HOME}"

# run the cmake wrapper
RUN \
cd "${TRINITYCORE_SOURCE_DIR}" && \
mkdir -p "${TRINITYCORE_BUILD_DIR}" && \
cd "${TRINITYCORE_BUILD_DIR}" && \
"$HOME/cmake.sh" "${CMAKE_FLAGS}" ../
