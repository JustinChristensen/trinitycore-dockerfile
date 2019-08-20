FROM trinitycore-compile

LABEL \
maintainer="justin@promise.io" \
version="1.0.0"

ARG BIN_DIR="/usr/local/bin"
ARG CLIENT="client"
ARG TRINITY_USER="trinity"
ARG TRINITY_USER_HOME="/home/${TRINITY_USER}"
ARG TRINITY_DIR="${TRINITY_USER_HOME}/server"
ARG TRINITY_BIN_DIR="${TRINITY_DIR}/bin"
ARG TRINITY_DATA_DIR="${TRINITY_DIR}/data"
ARG TRINITY_VERSION="3.3.5"

ENV \
TRINITY_VERSION=${TRINITY_VERSION} \
WORLD_DB_RELEASE="https://github.com/TrinityCore/TrinityCore/releases/download/TDB335.19081/TDB_full_world_335.19081_2019_08_16.7z"

# add the client
ADD ${CLIENT} ${CLIENT}

# create the data directory, and extract the client's data
RUN mkdir -p "${TRINITY_DATA_DIR}"
WORKDIR ${CLIENT}

# run each of these separately to avoid losing
# progress in the event a rebuild is needed
RUN ${TRINITY_BIN_DIR}/mapextractor
RUN ${TRINITY_BIN_DIR}/vmap4extractor
RUN ${TRINITY_BIN_DIR}/vmap4assembler
RUN ${TRINITY_BIN_DIR}/mmaps_generator

# move the extracted data, clean up, and create
# the server configs
RUN \
mv dbc maps vmaps mmaps "${TRINITY_DATA_DIR}" && \
cd ../ && rm -r "${CLIENT}" && \
rm ${TRINITY_BIN_DIR}/mapextractor \
    ${TRINITY_BIN_DIR}/vmap4extractor \
    ${TRINITY_BIN_DIR}/vmap4assembler \
    ${TRINITY_BIN_DIR}/mmaps_generator && \
sed 's|^DataDir = "."|DataDir = "${TRINITY_DATA_DIR}"|g; \
     s|^Updates.EnableDatabases *= *[[:digit:]]|Updates.EnableDatabases = 0|g; \
     s|^Updates.AutoSetup *= *[[:digit:]]|Updates.AutoSetup = 0|g;' \
     etc/worldserver.conf.dist > etc/worldserver.conf && \
sed 's|^Updates.EnableDatabases *= *[[:digit:]]|Updates.EnableDatabases = 0|g; \
     s|^Updates.AutoSetup *= *[[:digit:]]|Updates.AutoSetup = 0|g;' \
     etc/authserver.conf.dist > etc/authserver.conf && \
rm etc/*.dist

WORKDIR ${TRINITY_BIN_DIR}

# authserver
EXPOSE 3724/tcp

# worldserver
EXPOSE 8085/tcp

# copy and set the entry point
COPY docker-entrypoint.sh ${BIN_DIR}
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["worldserver"]
