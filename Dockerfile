FROM library/debian:stable-20201012-slim
RUN DEBIAN_FRONTEND="noninteractive" && \
    apt-get update && \
    apt-get install --no-install-recommends --assume-yes \
        bzip2=1.0.6-9.2~deb10u1 \
        ca-certificates=20190110 && \
    rm -r /var/lib/apt/lists /var/cache/apt

# App user
ARG APP_USER="fah"
ARG APP_UID=1362
RUN useradd --uid "$APP_UID" --user-group --no-create-home --shell /sbin/nologin "$APP_USER"

# Folding@Home package
ARG FAH_PKG="fahclient"
ARG ARCHIVE_URL="https://download.foldingathome.org/releases/public/release/fahclient/debian-stable-64bit/v7.6/fahclient_7.6.21_amd64.deb"
ADD "$ARCHIVE_URL" "$FAH_PKG.deb"
RUN DEBIAN_FRONTEND="noninteractive" \
    dpkg --unpack "$FAH_PKG.deb" && \
    rm /var/lib/dpkg/info/fahclient.postinst && \
    dpkg --configure "$FAH_PKG" && \
    rm "$FAH_PKG.deb"

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