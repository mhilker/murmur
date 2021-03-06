FROM debian:stretch as base

RUN apt-get update \
 && apt-get install -y \
    curl \
    bzip2 \
    gnupg \
 && rm -rf /var/lib/apt/lists/*
RUN mkdir -p /opt/murmur/
# Install murmur
RUN curl -XGET "https://raw.githubusercontent.com/mumble-voip/mumble-gpg-signatures/master/mumble-auto-build-2019.asc" -o /tmp/key.asc \
 && gpg --import /tmp/key.asc \
 && rm /tmp/key.asc \
 && curl -XGET "https://dl.mumble.info/murmur-static_x86-1.3.0.tar.bz2" -o /tmp/murmur.tar.bz2 \
 && curl -XGET "https://dl.mumble.info/murmur-static_x86-1.3.0.tar.bz2.sig" -o /tmp/murmur.sig \
 && gpg --verify /tmp/murmur.sig /tmp/murmur.tar.bz2 \
 && rm /tmp/murmur.sig \
 && tar -xvjf /tmp/murmur.tar.bz2 -C /tmp \
 && rm /tmp/murmur.tar.bz2 \
 && cp -R /tmp/murmur-static*/* /opt/murmur/ \
 && rm -rf /tmp/*

FROM debian:stretch as production
RUN mkdir -p /opt/murmur/ \
 && mkdir -p /var/lib/murmur/ \
 && mkdir -p /etc/murmur/
COPY --from=base /opt/murmur/ /opt/murmur/
COPY murmur.ini /etc/murmur/murmur.ini
RUN adduser --home /opt/murmur/ --disabled-password --gecos '' murmur \
 && chown -R murmur:murmur /opt/murmur \
 && chown -R murmur:murmur /var/lib/murmur
EXPOSE 6502
EXPOSE 64738
EXPOSE 64738/udp
VOLUME ["/var/lib/murmur/"]
CMD ["/opt/murmur/murmur.x86", "-fg", "-ini", "/etc/murmur/murmur.ini"]
