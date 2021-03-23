FROM debian:stretch-slim
MAINTAINER telworks <oleg.itsm@gmail.com>
ENV build_date 2021-03-23

RUN apt-get update
WORKDIR /tmp/
RUN mkdir asterisk
WORKDIR /tmp/asterisk

RUN useradd --system asterisk

RUN DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends --no-install-suggests \
    autoconf \
    binutils-dev \
    build-essential \
    ca-certificates \
    curl \
    file \
    libcurl4-openssl-dev \
    libedit-dev \
    libgsm1-dev \
    libogg-dev \
    libpopt-dev \
    libresample1-dev \
    libspandsp-dev \
    libspeex-dev \
    libspeexdsp-dev \
    libsqlite3-dev \
    libsrtp0-dev \
    libssl-dev \
    libvorbis-dev \
    libxml2-dev \
    libxslt1-dev \
    procps \
    portaudio19-dev \
    unixodbc \
    unixodbc-bin \
    unixodbc-dev \
    odbcinst \
    uuid \
    uuid-dev \
    xmlstarlet\
    wget\
    git

RUN curl -vsL http://downloads.asterisk.org/pub/telephony/asterisk/asterisk-18-current.tar.gz | tar --strip-components 1 -xz

RUN ./configure --with-jansson-bundled  --libdir=/usr/lib64 #1> /dev/null
# Remove the native build option
RUN make menuselect.makeopts
RUN menuselect/menuselect \
  --disable BUILD_NATIVE \
  --disable chan_sip \
  --enable cdr_csv \
  --enable chan_pjsip \
  --enable res_snmp \
  --enable res_http_websocket \
  menuselect.makeopts

# Continue with a standard make.
RUN make -j 8 all  # 1> /dev/null
RUN make install # 1> /dev/null
#RUN make samples # 1> /dev/null
RUN make basic-pbx
RUN make config

WORKDIR /

# Update max number of open files.
RUN sed -i -e 's/# MAXFILES=/MAXFILES=/' /usr/sbin/safe_asterisk
# Set tty
RUN sed -i 's/TTY=9/TTY=/g' /usr/sbin/safe_asterisk
# Create and configure asterisk for running asterisk user.
#RUN useradd -m asterisk -s /sbin/nologin
RUN chown asterisk:asterisk /var/run/asterisk
RUN chown -R asterisk:asterisk /etc/asterisk/
RUN chown -R asterisk:asterisk /var/lib/asterisk
RUN chown -R asterisk:asterisk /var/log/asterisk
RUN chown -R asterisk:asterisk /var/spool/asterisk
RUN chown -R asterisk:asterisk /usr/lib64/asterisk/

RUN echo [general] > /etc/asterisk/rtp.conf
RUN echo rtpstart=10000 >> /etc/asterisk/rtp.conf
RUN echo rtpend=10200>> /etc/asterisk/rtp.conf

# Running asterisk with user asterisk.
CMD /usr/sbin/asterisk -f -U asterisk -G asterisk -vvvg -c
