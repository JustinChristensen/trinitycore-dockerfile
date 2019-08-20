FROM trinitycore-extract

LABEL \
maintainer="justin@promise.io" \
version="1.0.0"

ARG BIN_DIR="/usr/local/bin"

EXPOSE 3443/tcp
EXPOSE 8085/tcp

# copy and set the entry point
COPY docker-entrypoint.sh ${BIN_DIR}
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["./worldserver"]
