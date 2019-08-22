FROM trinitycore-base

LABEL \
maintainer="justin@promise.io" \
version="1.0.0"

ARG BUILD_VERBOSE
ARG BUILD_JOBS=4
ARG TRINITYCORE_USER_HOME="/root"
ARG TRINITYCORE_SOURCE_DIR="${TRINITYCORE_USER_HOME}/TrinityCore"
ARG TRINITYCORE_BUILD_DIR="${TRINITYCORE_SOURCE_DIR}/build"
ARG TRINITYCORE_INSTALL_PREFIX="/usr/local"
ARG TRINITYCORE_LOG_DIR="/var/log/authserver"

ENV \
MYSQL_ADMIN_USER="root" \
MYSQL_ADMIN_PASS="root" \
MYSQL_USER="trinity" \
MYSQL_PASS="trinity" \
MYSQL_PASS_FILE="" \
MYSQL_HOST="127.0.0.1" \
MYSQL_PORT="3306" \
TRINITYCORE_INSTALL_PREFIX="${TRINITYCORE_INSTALL_PREFIX}"

WORKDIR ${TRINITYCORE_BUILD_DIR}

# build and remove build-time dependencies
RUN \
# build and install
make -j${BUILD_JOBS} VERBOSE=${BUILD_VERBOSE} authserver && \
make -Csrc/server/authserver install && \
# copy the sql files
cd ../ && cp \
    sql/create/create_mysql.sql \
    sql/base/auth_database.sql \
    "${TRINITYCORE_USER_HOME}" && \
cp -r sql/updates "{TRINITYCORE_USER_HOME}" && \
# remove the sources
cd ../ && rm -r "${TRINITYCORE_SOURCE_DIR}" TrinityCore.tar.gz && \
mkdir -p "${TRINITYCORE_LOG_DIR}" && \
# update the configuration
sed 's|^Updates.EnableDatabases *= *[[:digit:]]|Updates.EnableDatabases = 0|g; \
     s|^Updates.AutoSetup *= *[[:digit:]]|Updates.AutoSetup = 0|g; \
     s|^LogsDir *= *""|LogsDir = "${TRINITYCORE_LOG_DIR}"|g;' \
     "${TRINITYCORE_INSTALL_PREFIX}/etc/authserver.conf.dist" > "${TRINITYCORE_INSTALL_PREFIX}/etc/authserver.conf" && \
# remove the dependencies
apt-get purge -y \
    clang \
    cmake \
    curl \
    make \
    p7zip && \
apt-get autoremove -y && \
apt-get clean -y

WORKDIR ${TRINITYCORE_USER_HOME}

EXPOSE 3724/tcp

# copy and set the entrypoint
COPY docker-entrypoint.sh /usr/local/bin
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["authserver"]
