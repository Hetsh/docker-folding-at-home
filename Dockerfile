FROM library/debian:stable-20200514-slim
RUN DEBIAN_FRONTEND="noninteractive" && \
    apt-get update && \
    apt-get install --assume-yes \
        bzip2=1.0.6-9.2~deb10u1 \
        ca-certificates=20190110

# App user
ARG APP_USER="fah"
ARG APP_UID=1362
RUN useradd --uid "$APP_UID" --user-group --no-create-home --shell /sbin/nologin "$APP_USER"

# Folding@Home package
ARG FAH_DIR="/opt/folding-at-home"
ARG FAH_ARCHIVE="fah.tar.bz2"
ARG ARCHIVE_URL="https://download.foldingathome.org/releases/public/release/fahclient/debian-stable-64bit/v7.6/fahclient_7.6.13-64bit-release.tar.bz2"
ADD "$ARCHIVE_URL" "$FAH_DIR/$FAH_ARCHIVE"
RUN tar --extract --directory "$FAH_DIR" --file "$FAH_DIR/$FAH_ARCHIVE" --strip-components=1 && \
    apt-get purge -y bzip2 && \
    rm -r "$FAH_DIR/$FAH_ARCHIVE" /var/lib/apt/lists /var/cache/apt
ENV PATH="$FAH_DIR:$PATH"

# Volumes
ARG DATA_DIR="/folding-at-home"
RUN mkdir "$DATA_DIR" && \
    chown -R "$APP_USER":"$APP_USER" "$DATA_DIR"
VOLUME ["$DATA_DIR"]

#      WEB      CONTROL
EXPOSE 7396/tcp 36330/tcp

USER "$APP_USER"
WORKDIR "$DATA_DIR"
ENTRYPOINT ["FAHClient"]