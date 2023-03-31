ARG baseImage=alse:latest
FROM ${baseImage} AS prepare

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y --no-install-recommends locales && \
    localedef -i ru_RU -c -f UTF-8 -A /usr/share/locale/locale.alias ru_RU.UTF-8

ENV LANG=ru_RU.UTF-8

COPY ./distr /tmp/distr

ARG PLATFORM_VERSION
ENV PLATFORM_VERSION=${PLATFORM_VERSION}

RUN set -xe; cd /tmp/distr && \
    tar -xzf server64_${PLATFORM_VERSION}.tar.gz && \
    ./setup-full-${PLATFORM_VERSION}-x86_64.run --enable-components client_full,ru,server_admin --installer-language ru --debuglevel 4 && \
    chmod -R g+w /opt/1cv8
# --mode unattended

FROM ${baseImage} AS final

ARG DEBIAN_FRONTEND=noninteractive

COPY --from=prepare /opt/1cv8 /opt/1cv8

# install common packages
RUN apt-get update && \
     apt-get install -y --no-install-recommends \
    curl \
    locales \
    dbus-x11 \
    procps \
    libmono-i18n4.0-all \
    libwebkitgtk-3.0-0 \
    xvfb \
    x11vnc \
    at-spi2-core && \
    apt-get clean; rm -rf /var/lib/apt/lists /var/cache/debconf

# install fonts, locales
RUN echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true | debconf-set-selections && \
    curl -Lk -O http://ftp.ru.debian.org/debian/pool/contrib/m/msttcorefonts/ttf-mscorefonts-installer_3.6_all.deb && \
    apt-get update && apt-get install -y --no-install-recommends --fix-broken ./ttf-mscorefonts-installer_3.6_all.deb && \
    localedef -i ru_RU -c -f UTF-8 -A /usr/share/locale/locale.alias ru_RU.UTF-8 && \
    apt-get clean; rm -rf /var/lib/apt/lists /var/cache/debconf

ENV LANG=ru_RU.UTF-8

# Install oscript
RUN curl -Lk -O https://github.com/EvilBeaver/OneScript/releases/download/v1.8.3/onescript-engine_1.8.3_all.deb && \
    apt-get update && apt-get install -y ./onescript-engine_1.8.3_all.deb && \
    apt-get clean; rm -rf /var/lib/apt/lists /var/cache/debconf && \
    opm install vanessa-runner gitsync add

# Install scrot
RUN echo "deb http://deb.debian.org/debian bullseye main" >> /etc/apt/sources.list && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 605C66F00D6C9793 && \
    apt-get update && apt-get install -y scrot && \
    apt-get clean; rm -rf /var/lib/apt/lists /var/cache/debconf

ARG PLATFORM_VERSION
ENV PLATFORM_VERSION=${PLATFORM_VERSION}
ENV PLATFORM_PATH=/opt/1cv8/x86_64/${PLATFORM_VERSION}
# ENV CONF_PATH=/opt/1cv8/conf
ENV CONF_PATH=${PLATFORM_PATH}/conf

# Add path 1c
ENV PATH=${PLATFORM_PATH}:${PATH}

# disable unsafe protection
RUN echo "DisableUnsafeActionProtection=.*" >> ${CONF_PATH}/conf.cfg

# vnc
ARG RESOLUTION=1920x1080x24
ENV RESOLUTION=${RESOLUTION}
ARG VNC_PORT=9000
ENV VNC_PORT=${VNC_PORT}

# display
ENV DISPLAY=:99

# OKD/k8s user impl
ARG USER_ID=1001

RUN mkdir -p /home/usr1cv8 && \
    groupadd -f --gid $USER_ID grp1cv8 && \
    useradd --uid $USER_ID --gid $USER_ID --comment '1C Enterprise 8 server launcher' --no-log-init --create-home --home-dir /home/usr1cv8 usr1cv8 && \
    usermod -a -G 0 usr1cv8 && \
    chown -R ${USER_ID}:0 /home/usr1cv8 && chmod g+w /home/usr1cv8

# change user
USER ${USER_ID}

# Expose port vnc
EXPOSE $VNC_PORT

# Add volume
VOLUME /var/log/1C
VOLUME /home/usr1cv8

COPY client/entrypoint.sh /tmp/

ENTRYPOINT ["/bin/sh", "-x", "/tmp/entrypoint.sh"]

# for run startup menu 1c
CMD ["1cv8s"]
