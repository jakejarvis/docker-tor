FROM ubuntu:22.04

LABEL maintainer="Jake Jarvis <jake@jarv.is>" \
      repository="https://github.com/jakejarvis/docker-tor" \
      # https://docs.github.com/en/free-pro-team@latest/packages/managing-container-images-with-github-container-registry/connecting-a-repository-to-a-container-image#connecting-a-repository-to-a-container-image-on-the-command-line
      org.opencontainers.image.source="https://github.com/jakejarvis/docker-tor"

ARG DEBIAN_FRONTEND=noninteractive

# All the things!
RUN apt-get update && \
    apt-get install --no-install-recommends --no-install-suggests -y \
        ca-certificates \
        apt-transport-https \
        lsb-release \
        curl \
        gnupg && \
    # Add torproject.org repository for stable Tor
    curl -fsSL https://deb.torproject.org/torproject.org/A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89.asc | gpg --dearmor -o /usr/share/keyrings/tor-archive-keyring.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/tor-archive-keyring.gpg] https://deb.torproject.org/torproject.org $(lsb_release -cs) main" | tee -a /etc/apt/sources.list.d/tor.list && \
    echo "deb-src [signed-by=/usr/share/keyrings/tor-archive-keyring.gpg] https://deb.torproject.org/torproject.org $(lsb_release -cs) main" | tee -a /etc/apt/sources.list.d/tor.list && \
    # Install Tor with GeoIP
    apt-get update && \
    apt-get install --no-install-recommends --no-install-suggests -y \
        tor \
        tor-geoipdb \
        obfs4proxy \
        iputils-ping \
        gosu && \
    # Tidy up
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Copy a simple default config
COPY torrc.default /etc/tor/torrc

# Copy entrypoint script & ensure it's executable
COPY entrypoint.sh /usr/local/bin/docker-entrypoint

HEALTHCHECK --interval=300s --timeout=10s --start-period=30s \
  CMD curl -sSx socks5h://127.0.0.1:9050 https://check.torproject.org/api/ip | grep -E '"IsTor"\s*:\s*true'

ENTRYPOINT ["docker-entrypoint"]
