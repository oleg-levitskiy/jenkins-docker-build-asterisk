FROM debian:stretch-slim
MAINTAINER telworks <oleg.itsm@gmail.com>
ENV build_date 2021-03-23

RUN apt-get update

# Download asterisk.
WORKDIR /tmp/
#RUN git clone -b certified/11.6 --depth 1 https://gerrit.asterisk.org/asterisk
RUN mkdir asterisk
RUN apt install -y wget
RUN wget http://downloads.asterisk.org/pub/telephony/asterisk/asterisk-16-current.tar.gz
RUN tar -xvf asterisk-16-current.tar.gz -C asterisk
RUN ls /tmp/asterisk
WORKDIR /tmp/asterisk/asterisk-16.6.1
