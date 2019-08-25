FROM trinitycore-base

LABEL \
maintainer="justin@promise.io" \
version="1.0.0"

ARG BUILD_VERBOSE
ARG BUILD_JOBS=4
ARG BUILD_TOOLS=1
ARG TRINITYCORE_USER_HOME="/root"
ARG TRINITYCORE_SOURCE_DIR="${TRINITYCORE_USER_HOME}/TrinityCore"
ARG TRINITYCORE_BUILD_DIR="${TRINITYCORE_SOURCE_DIR}/build"
ARG TRINITYCORE_INSTALL_PREFIX="/usr/local"
ARG TRINITYCORE_BIN_DIR="${TRINITYCORE_INSTALL_PREFIX}/bin"
ARG TRINITYCORE_DATA_DIR="${TRINITYCORE_INSTALL_PREFIX}/data"
ARG TRINITYCORE_LOG_DIR="/var/log/worldserver"

ENV \
MYSQL_ADMIN_USER="root" \
MYSQL_ADMIN_PASS="root" \
MYSQL_USER="trinity" \
MYSQL_PASS="trinity" \
MYSQL_PASS_FILE="" \
MYSQL_HOST="127.0.0.1" \
MYSQL_PORT="3306" \
TRINITYCORE_INSTALL_PREFIX="${TRINITYCORE_INSTALL_PREFIX}" \
TRINITYCORE_DATA_DIR="${TRINITYCORE_DATA_DIR}" \
WORLD_DB_RELEASE="https://github.com/TrinityCore/TrinityCore/releases/download/TDB335.19081/TDB_full_world_335.19081_2019_08_16.7z" \
EXTRACT_DATA="${BUILD_TOOLS}" \
CREATE_DATABASES=1 \
CONNECT_RETRIES=6 \
RETRY_INTERVAL=5

WORKDIR ${TRINITYCORE_BUILD_DIR}

# build and remove build-time dependencies
RUN \
# build and install
make -j${BUILD_JOBS} VERBOSE=${BUILD_VERBOSE} worldserver && \
make -Csrc/server/worldserver install && \
if [ "${BUILD_TOOLS}" = "1" ]; then \
	make -j${BUILD_JOBS} VERBOSE=${BUILD_VERBOSE} src/tools && \
	make -Csrc/tools install; \
fi && \
# copy the sql files
cd ../ && cp \
    sql/create/create_mysql.sql \
    sql/base/auth_database.sql \
	sql/base/characters_database.sql \
    "${TRINITYCORE_USER_HOME}" && \
cp -r sql/updates "${TRINITYCORE_USER_HOME}" && \
# remove the sources
cd ../ && rm -r "${TRINITYCORE_SOURCE_DIR}" TrinityCore.tar.gz && \
mkdir -p "${TRINITYCORE_LOG_DIR}" && \
# update the configuration
sed 's|^Updates.EnableDatabases *= *[[:digit:]]|Updates.EnableDatabases = 0|g; \
     s|^Updates.AutoSetup *= *[[:digit:]]|Updates.AutoSetup = 0|g; \
     s|^Console.Enable *= *[[:digit:]]|Console.Enable = 0|g; \
     s|^LogsDir *= *""|LogsDir = "'${TRINITYCORE_LOG_DIR}'"|g; \
     s|^Ra.Enable *= *[[:digit:]]|Ra.Enable = 1|g;' \
     "${TRINITYCORE_INSTALL_PREFIX}/etc/worldserver.conf.dist" > "${TRINITYCORE_INSTALL_PREFIX}/etc/worldserver.conf" && \
# remove the dependencies
apt-get purge -y \
    clang \
    cmake \
    make && \
apt-get autoremove -y && \
apt-get clean -y

WORKDIR ${TRINITYCORE_USER_HOME}

VOLUME ${TRINITYCORE_DATA_DIR}

EXPOSE 3443/tcp
EXPOSE 8085/tcp

# copy and set the entry point
COPY docker-entrypoint.sh /usr/local/bin
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["worldserver"]
