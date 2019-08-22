FROM trinitycore-base

LABEL \
maintainer="justin@promise.io" \
version="1.0.0"

ARG BUILD_VERBOSE
ARG BUILD_JOBS=4
ARG BUILD_TOOLS=1
ARG TRINITY_USER_HOME="/root"
ARG TRINITY_REPO_DIR="${TRINITY_USER_HOME}/TrinityCore"
ARG TRINITY_BUILD_DIR="${TRINITY_REPO_DIR}/build"
ARG TRINITY_INSTALL_PREFIX="/usr/local"
ARG TRINITY_BIN_DIR="${TRINITY_INSTALL_PREFIX}/bin"
ARG TRINITY_DATA_DIR="${TRINITY_INSTALL_PREFIX}/data"
ARG CLIENT_DIR="${TRINITY_DATA_DIR}/client"
ARG TRINITY_LOG_DIR="/var/log/worldserver"

ENV \
MYSQL_USER="trinity" \
MYSQL_PASS="trinity" \
MYSQL_PASS_FILE="" \
MYSQL_HOST="127.0.0.1" \
MYSQL_PORT="3306" \
TRINITY_INSTALL_PREFIX="${TRINITY_INSTALL_PREFIX}" \
TRINITY_DATA_DIR="${TRINITY_DATA_DIR}" \
WORLD_DB_RELEASE="https://github.com/TrinityCore/TrinityCore/releases/download/TDB335.19081/TDB_full_world_335.19081_2019_08_16.7z" \
EXTRACT_DATA="${BUILD_TOOLS}" \
CLIENT_DIR="${CLIENT_DIR}"

WORKDIR ${TRINITY_BUILD_DIR}

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
    "${TRINITY_USER_HOME}" && \
cp -r sql/updates "{TRINITY_USER_HOME}" && \
# remove the repo
cd ../ && rm -r "${TRINITY_REPO_DIR}" && \
mkdir -p "${TRINITY_LOG_DIR}" && \
# update the configuration
sed 's|^Updates.EnableDatabases *= *[[:digit:]]|Updates.EnableDatabases = 0|g; \
     s|^Updates.AutoSetup *= *[[:digit:]]|Updates.AutoSetup = 0|g; \
     s|^Console.Enable *= *[[:digit:]]|Console.Enable = 0|g; \
     s|^LogsDir *= *""|LogsDir = "${TRINITY_LOG_DIR}"|g; \
     s|^Ra.Enable *= *[[:digit:]]|Ra.Enable = 1|g;' \
     "${TRINITY_INSTALL_PREFIX}/etc/worldserver.conf.dist" > "${TRINITY_INSTALL_PREFIX}/etc/worldserver.conf" && \
# remove the dependencies
apt-get purge -y \
    clang \
    cmake \
    git \
    make && \
apt-get autoremove -y && \
apt-get clean -y

WORKDIR ${TRINITY_USER_HOME}

VOLUME ${TRINITY_DATA_DIR}

EXPOSE 3443/tcp
EXPOSE 8085/tcp

# copy and set the entry point
COPY docker-entrypoint.sh /usr/local/bin
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["worldserver"]
