FROM trinitycore-base

LABEL \
maintainer="justin@promise.io" \
version="1.0.0"

ARG BUILD_VERBOSE
ARG BUILD_JOBS=4
ARG TRINITY_USER_HOME="/root"
ARG TRINITY_REPO_DIR="${TRINITY_USER_HOME}/TrinityCore"
ARG TRINITY_BUILD_DIR="${TRINITY_REPO_DIR}/build"
ARG TRINITY_INSTALL_PREFIX="/usr/local"
ARG TRINITY_LOG_DIR="/var/log/authserver"

ENV \
MYSQL_USER="trinity" \
MYSQL_PASS="trinity" \
MYSQL_PASS_FILE="" \
MYSQL_HOST="127.0.0.1" \
MYSQL_PORT="3306" \
TRINITY_INSTALL_PREFIX="${TRINITY_INSTALL_PREFIX}"

WORKDIR ${TRINITY_BUILD_DIR}

# build and remove build-time dependencies
RUN \
# build and install
make -j${BUILD_JOBS} VERBOSE=${BUILD_VERBOSE} authserver && \
make -Csrc/server/authserver install && \
# copy the sql files
cd ../ && cp \
    sql/create/create_mysql.sql \
    sql/base/auth_database.sql \
    "${TRINITY_USER_HOME}" && \
cp -r sql/updates "{TRINITY_USER_HOME}" && \
# remove the repo
cd ../ && rm -r "${TRINITY_REPO_DIR}" && \
mkdir -p "${TRINITY_LOG_DIR}" && \
# update the configuration
sed 's|^Updates.EnableDatabases *= *[[:digit:]]|Updates.EnableDatabases = 0|g; \
     s|^Updates.AutoSetup *= *[[:digit:]]|Updates.AutoSetup = 0|g; \
     s|^LogsDir *= *""|LogsDir = "${TRINITY_LOG_DIR}"|g;' \
     "${TRINITY_INSTALL_PREFIX}/etc/authserver.conf.dist" > "${TRINITY_INSTALL_PREFIX}/etc/authserver.conf" && \
# remove the dependencies
apt-get purge -y \
    clang \
    cmake \
    curl \
    git \
    make \
    p7zip && \
apt-get autoremove -y && \
apt-get clean -y

WORKDIR ${TRINITY_USER_HOME}

EXPOSE 3724/tcp

# copy and set the entrypoint
COPY docker-entrypoint.sh /usr/local/bin
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["authserver"]
