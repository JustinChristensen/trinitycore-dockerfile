FROM debian:buster-slim

LABEL \
maintainer="justin@promise.io" \
version="1.0.0"

ARG BUILD_VERBOSE
ARG BUILD_JOBS=4
ARG TRINITY_REPO="https://github.com/TrinityCore/TrinityCore.git"
ARG TRINITY_REPO_DIR="TrinityCore"
ARG TRINITY_BUILD_DIR="build"
ARG TRINITY_USER_HOME="/root"
ARG TRINITY_DIR="${TRINITY_USER_HOME}/server"
ARG TRINITY_BIN_DIR="${TRINITY_DIR}/bin"
ARG CMAKE_FLAGS="-DCMAKE_INSTALL_PREFIX=${TRINITY_DIR}"
ARG TRINITY_VERSION="3.3.5"

ENV \
TRINITY_VERSION=${TRINITY_VERSION}

# install trinitycore dependencies and add the trinity user
RUN \
apt-get update && \
apt-get install -y \
curl \
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
mariadb-client \
p7zip && \
update-alternatives --install /usr/bin/cc cc /usr/bin/clang 100 && \
update-alternatives --install /usr/bin/c++ c++ /usr/bin/clang 100

# groupadd -r "${TRINITY_USER}" && \
# useradd -m -r -g "${TRINITY_USER}" -d "${TRINITY_USER_HOME}" -s /bin/bash "${TRINITY_USER}"

# su to the trinitycore user
WORKDIR ${TRINITY_USER_HOME}

# pull down trinitycore
RUN git clone --depth=1 -b "${TRINITY_VERSION}" "${TRINITY_REPO}" "${TRINITY_REPO_DIR}"

# build and then clean up
RUN \
cd "${TRINITY_REPO_DIR}" && \
mkdir -p "${TRINITY_BUILD_DIR}" && cd "${TRINITY_BUILD_DIR}" && cmake ../ "${CMAKE_FLAGS}" && \
make -j${BUILD_JOBS} VERBOSE=${BUILD_VERBOSE} && make install && cd ../ && \
cp \
sql/create/create_mysql.sql \
sql/base/auth_database.sql \
sql/base/characters_database.sql \
"${TRINITY_BIN_DIR}" && \
cp -r sql/updates "{TRINITY_BIN_DIR}" && \
cd ../ && rm -r "${TRINITY_REPO_DIR}" && \
chown -R ${TRINITY_USER}:${TRINITY_USER} "${TRINITY_DIR}"

# cd to the app directory
WORKDIR ${TRINITY_DIR}
