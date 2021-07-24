FROM library/debian:stable-20210721-slim
ARG DEBIAN_FRONTEND="noninteractive"
RUN apt update && \
    apt install --no-install-recommends --assume-yes \
        bzip2=1.0.6-9.2~deb10u1 \
        ca-certificates=20200601~deb10u2 && \
    rm -r /var/lib/apt/lists /var/cache/apt

# App user
ARG APP_USER="fah"
ARG APP_UID=1362
RUN useradd --uid "$APP_UID" --user-group --no-create-home --shell /sbin/nologin "$APP_USER"

# Folding@Home package
ARG PKG_URL="https://download.foldingathome.org/releases/public/release/fahclient/debian-stable-64bit/v7.6/fahclient_7.6.21_amd64.deb"
RUN apt update && \
    apt install --no-install-recommends --assume-yes wget && \
    wget --quiet "$PKG_URL" && \
    apt purge --assume-yes --auto-remove wget && \
    rm -r /var/lib/apt/lists /var/cache/apt && \
    dpkg --unpack *.deb && \
    rm *.deb /var/lib/dpkg/info/fahclient.postinst && \
    dpkg --configure "fahclient"

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
