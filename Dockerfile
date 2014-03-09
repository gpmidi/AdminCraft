FROM ubuntu:13.04
MAINTAINER Paulson McIntyre, paul+mark2docker@gpmidi.net

RUN groupadd --gid 1000 mcservers \
  && useradd --home-dir "/var/lib/minecraft" -m --gid 1000 --uid 1000 mcservers

# Do an initial update
RUN apt-get update
RUN apt-get dist-upgrade -y

# Stuff pip will require
RUN apt-get install -y \
  build-essential git python python-dev \
  python-setuptools python-pip wget curl \
  openjdk-7-jre-headless curl rdiff-backup \
  python-openssl libssl-dev \
  supervisor logrotate cron

RUN mkdir -p /var/log/supervisord && \
  chmod 700 /var/log/supervisord/

# Various configs
ADD ./ /usr/share/minecraft/    
RUN  cp /usr/share/minecraft/supervisord.d/*.conf /etc/supervisor/conf.d/ \
  && cp /usr/share/minecraft/logrotate.d/*.conf /etc/logrotate.d/ \
  && apt-get -yq install openssh-server vim \
  && mkdir -p /var/run/sshd \
  && chmod 755 /var/run/sshd \
  && mkdir /root/.ssh \
  && chmod 700 /root/.ssh \
  && cp /usr/share/minecraft/authorized_keys /root/.ssh/authorized_keys \
  && chmod -R 755 /var/lib/minecraft/ \
  && cp -a /var/lib/minecraft/ \
  && cd /usr/share/minecraft/ \
  && /usr/bin/python /usr/share/minecraft/setup.py install \
  && chmod 400 /root/.ssh/authorized_keys \
  && chown root:root /root/.ssh/authorized_keys \
  && chown -R 1000.1000 /var/lib/minecraft \
  && chmod -R 755 /var/lib/minecraft \
  && wget -O /var/lib/minecraft/minecraft.jar https://s3.amazonaws.com/Minecraft.Download/versions/1.7.4/minecraft_server.1.7.4.jar

#RUN apt-get remove -y \
#  build-essential openssh-server vim

EXPOSE 22 25565
VOLUME ["/var/lib/minecraft","/root/.ssh/"]
CMD ["supervisord", "--nodaemon", "--logfile=/var/log/supervisord/supervisord.log", "--loglevel=warn", "--logfile_maxbytes=1GB", "--logfile_backups=0"]

