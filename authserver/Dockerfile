FROM trinitycore-extract

LABEL \
maintainer="justin@promise.io" \
version="1.0.0"

ARG BIN_DIR="/usr/local/bin"

# authserver
EXPOSE 3724/tcp

# copy and set the entry point
COPY docker-entrypoint.sh ${BIN_DIR}
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["./authserver"]
