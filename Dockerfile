FROM debian:buster-slim

LABEL \
maintainer="justin@promise.io" \
version="1.0.0"

ARG BIN_DIR="/usr/local/bin"
ARG BUILD_VERBOSE
ARG BUILD_JOBS=4
ARG CLIENT="client"
ARG TRINITY_USER="trinity"
ARG TRINITY_REPO="https://github.com/TrinityCore/TrinityCore.git"
ARG TRINITY_REPO_DIR="TrinityCore"
ARG TRINITY_BUILD_DIR="build"
ARG TRINITY_USER_HOME="/home/${TRINITY_USER}"
ARG TRINITY_DIR="${TRINITY_USER_HOME}/server"
ARG CMAKE_FLAGS="-DCMAKE_INSTALL_PREFIX=${TRINITY_DIR}"
ARG TRINITY_VERSION="3.3.5"

ENV \
TRINITY_VERSION=${TRINITY_VERSION}

# install trinitycore dependencies and add the trinity user
RUN \
apt-get update && \
apt-get install -y \
gcc \
g++ \
clang \
cmake \
default-libmysqlclient-dev \
git \
libmariadbclient-dev \
libssl-dev \
libbz2-dev \
libreadline-dev \
libncurses-dev \
libboost-all-dev \
make \
mariadb-server \
p7zip && \
update-alternatives --install /usr/bin/cc cc /usr/bin/clang 100 && \
update-alternatives --install /usr/bin/c++ c++ /usr/bin/clang 100 && \
groupadd -r "${TRINITY_USER}" && \
useradd -m -r -g "${TRINITY_USER}" -d "${TRINITY_USER_HOME}" -s /bin/bash "${TRINITY_USER}"

# su to the trinitycore user
WORKDIR ${TRINITY_USER_HOME}
USER ${TRINITY_USER}
   
# pull down trinitycore
# ADD --chown=trinity:trinity TrinityCore TrinityCore
RUN git clone -b "${TRINITY_VERSION}" "${TRINITY_REPO}" "${TRINITY_REPO_DIR}"

# build
RUN \
cd "${TRINITY_REPO_DIR}" && \
mkdir -p "${TRINITY_BUILD_DIR}" && cd "${TRINITY_BUILD_DIR}" && cmake ../ "${CMAKE_FLAGS}" && \
make -j${BUILD_JOBS} VERBOSE=${BUILD_VERBOSE} && make install
 
# cd to the app directory
WORKDIR ${TRINITY_DIR}

# add the client
ADD --chown trinity:trinity ${CLIENT} ./

# extract it's data
# RUN 

COPY docker-entrypoint.sh ${BIN_DIR}
ENTRYPOINT ["docker-entrypoint.sh"]
