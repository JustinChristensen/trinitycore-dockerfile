FROM debian:buster-slim

LABEL \
maintainer="justin@promise.io" \
version="1.0.0"

ARG TRINITY_REPO="https://github.com/TrinityCore/TrinityCore.git"
ARG TRINITY_VERSION="3.3.5"
ARG TRINITY_USER_HOME="/root"
ARG TRINITY_REPO_DIR="${TRINITY_USER_HOME}/TrinityCore"
ARG TRINITY_BUILD_DIR="${TRINITY_REPO_DIR}/build"
ARG TRINITY_INSTALL_PREFIX="/usr/local"
ARG CMAKE_FLAGS="-DCMAKE_INSTALL_PREFIX=${TRINITY_INSTALL_PREFIX}"

# install trinitycore dependencies
RUN \
apt-get update && \
apt-get install -y \
    curl \
    clang \
    cmake \
    gnupg \
    git \
    libmariadb-dev-compat \
    libssl-dev \
    libbz2-dev \
    libreadline-dev \
    libncurses-dev \
    libboost-all-dev \
    make \
    mariadb-client \
    p7zip

WORKDIR ${TRINITY_USER_HOME}

# pull down trinitycore
RUN git clone --depth=1 -b "${TRINITY_VERSION}" "${TRINITY_REPO}" "${TRINITY_REPO_DIR}"

# add the cmake wrapper
ADD cmake.sh "${TRINITY_USER_HOME}"

# run the cmake wrapper
RUN \
cd "${TRINITY_REPO_DIR}" && \
mkdir -p "${TRINITY_BUILD_DIR}" && \
cd "${TRINITY_BUILD_DIR}" && \
"$HOME/cmake.sh" "${CMAKE_FLAGS}" ../
