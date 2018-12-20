FROM ubuntu:16.04

MAINTAINER Benny Brit <benny.brit@gmail.com>

# configure torrentv plugin playlist (for example http://xx.xx.xx.xx/trash/ttv-list/ttv.all.proxy.m3u?ip=127.0.0.1:8000)
# can be passed during build (--build-arg playlist=<playlist URL>)
ARG playlist=""

# update and install required packages
RUN DEBIAN_FRONTEND=noninteractive apt-get update -y
RUN DEBIAN_FRONTEND=noninteractive apt upgrade -y
RUN DEBIAN_FRONTEND=noninteractive apt install wget python unzip python-pip python-m2crypto python-apsw -y
RUN pip install gevent psutil

# install acestream
RUN wget http://dl.acestream.org/linux/acestream_3.1.16_ubuntu_16.04_x86_64.tar.gz
RUN tar zxvf acestream_3.1.16_ubuntu_16.04_x86_64.tar.gz
RUN rm acestream_3.1.16_ubuntu_16.04_x86_64.tar.gz
RUN mv acestream_3.1.16_ubuntu_16.04_x86_64/ /opt/acestream

# install HTTPAceProxy
RUN wget https://github.com/pepsik-kiev/HTTPAceProxy/archive/master.zip -O acehttp.zip
RUN unzip acehttp.zip -d /opt
RUN rm acehttp.zip
RUN mv /opt/HTTPAceProxy-master /opt/HTTPAceProxy

# configure HTTPAceProxy
RUN sed -i "s|acespawn = .*|acespawn = True|" /opt/HTTPAceProxy/aceconfig.py
RUN sed -i "s|acecmd = .*|acecmd = '/opt/acestream/acestreamengine --client-console --live-buffer 25 --vod-buffer 10 --vod-drop-max-age 120'|" /opt/HTTPAceProxy/aceconfig.py
RUN sed -i "s|url=.*|url='${playlist}'|" /opt/HTTPAceProxy/plugins/config/torrenttv.py

EXPOSE 8000

ENTRYPOINT ["python", "/opt/HTTPAceProxy/acehttp.py"]
