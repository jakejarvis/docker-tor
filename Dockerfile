FROM ubuntu:22.04
LABEL maintainer "Jake Jarvis <jake@jarv.is>"

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
 && apt-get install --no-install-recommends --no-install-suggests -y \
        ca-certificates \
        apt-transport-https \
        apt-utils \
        lsb-release \
        gnupg \
        curl \
 # Add torproject.org repository for stable Tor
 && curl -fsSL https://deb.torproject.org/torproject.org/A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89.asc | gpg --dearmor -o /usr/share/keyrings/tor-archive-keyring.gpg \
 && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/tor-archive-keyring.gpg] https://deb.torproject.org/torproject.org $(lsb_release -cs) main \
deb-src [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/tor-archive-keyring.gpg] https://deb.torproject.org/torproject.org $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/tor.list >/dev/null \
 # Install Tor with GeoIP
 && apt-get update \
 && apt-get install --no-install-recommends --no-install-suggests -y \
        tor \
        tor-geoipdb \
        obfs4proxy \
        iputils-ping \
 # Tidy up
 && apt-get purge --auto-remove -y \
        apt-transport-https \
        apt-utils \
        lsb-release \
        gnupg \
        curl \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# Copy entrypoint script
COPY ./entrypoint.sh /usr/local/bin/docker-entrypoint

USER debian-tor

ENTRYPOINT ["docker-entrypoint"]
CMD ["tor", "-f", "/etc/tor/torrc"]
