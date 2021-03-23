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

RUN ls
#RUN ./contrib/scripts/install_prereq install
RUN apt-get install -y libedit-dev  build-essential aptitude-common libboost-filesystem1.62.0 libboost-iostreams1.62.0\
  libboost-system1.62.0 libcgi-fast-perl libcgi-pm-perl libclass-accessor-perl\
  libcwidget3v5 libencode-locale-perl libfcgi-perl libgdbm3\
  libhtml-parser-perl libhtml-tagset-perl libhttp-date-perl\
  libhttp-message-perl libio-html-perl libio-string-perl\
  liblocale-gettext-perl liblwp-mediatypes-perl libparse-debianchangelog-perl\
  libperl5.24 libsigc++-2.0-0v5 libsqlite3-0 libsub-name-perl libtimedate-perl\
  liburi-perl libxapian30 netbase perl perl-modules-5.24 rename\
   apt-xapian-index debtags tasksel\
  libcwidget-dev libdata-dump-perl libhtml-template-perl libxml-simple-perl\
  libwww-perl xapian-tools perl-doc libterm-readline-gnu-perl\
  libterm-readline-perl-perl make\
  aptitude aptitude-common libboost-filesystem1.62.0 libboost-iostreams1.62.0\
  libboost-system1.62.0 libcgi-fast-perl libcgi-pm-perl libclass-accessor-perl\
  libcwidget3v5 libencode-locale-perl libfcgi-perl libgdbm3\
  libhtml-parser-perl libhtml-tagset-perl libhttp-date-perl\
  libhttp-message-perl libio-html-perl libio-string-perl\
  liblocale-gettext-perl liblwp-mediatypes-perl libparse-debianchangelog-perl\
  libperl5.24 libsigc++-2.0-0v5 libsqlite3-0 libsub-name-perl libtimedate-perl\
  liburi-perl libxapian30 netbase perl perl-modules-5.24 rename

RUN apt-get install -y sqlite3 uuid-dev apt-utils libjansson-dev  libjansson4 libxml2 libxml2-dev
RUN apt-get install -y libsqlite3-dev

RUN ls
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
RUN make # 1> /dev/null
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
RUN useradd -m asterisk -s /sbin/nologin
RUN chown asterisk:asterisk /var/run/asterisk
RUN chown -R asterisk:asterisk /etc/asterisk/
RUN chown -R asterisk:asterisk /var/lib/asterisk
RUN chown -R asterisk:asterisk /var/log/asterisk
RUN chown -R asterisk:asterisk /var/spool/asterisk
RUN chown -R asterisk:asterisk /usr/lib64/asterisk/

# Running asterisk with user asterisk.
CMD /usr/sbin/asterisk -f -U asterisk -G asterisk -vvvg -c
