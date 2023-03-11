FROM ubuntu:22.04

LABEL maintainer="Jake Jarvis <jake@jarv.is>" \
      repository="https://github.com/jakejarvis/tor-docker" \
      # https://docs.github.com/en/free-pro-team@latest/packages/managing-container-images-with-github-container-registry/connecting-a-repository-to-a-container-image#connecting-a-repository-to-a-container-image-on-the-command-line
      org.opencontainers.image.source="https://github.com/jakejarvis/tor-docker"

ARG TARGETPLATFORM
ARG DEBIAN_FRONTEND=noninteractive
# https://github.com/krallin/tini/releases
ARG TINI_VERSION=0.19.0

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
        iputils-ping && \
    # Install tini: https://github.com/krallin/tini
    if [ "${TARGETPLATFORM}" = "linux/arm64" ]; then \
      curl -s -L https://github.com/krallin/tini/releases/download/v${TINI_VERSION}/tini-arm64 -o /usr/local/bin/tini; \
    else \
      curl -s -L https://github.com/krallin/tini/releases/download/v${TINI_VERSION}/tini -o /usr/local/bin/tini; \
    fi && \
    chmod +x /usr/local/bin/tini && \
    # Tidy up
    apt-get purge --auto-remove -y \
        apt-transport-https \
        lsb-release \
        gnupg && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Copy a simple default config
COPY torrc.default /etc/tor/torrc

# Copy entrypoint script & ensure it's executable
COPY ./entrypoint.sh /usr/local/bin/docker-entrypoint
RUN chmod ugo+rx /usr/local/bin/docker-entrypoint

# Tor data should be persisted on the host
VOLUME /var/lib/tor

# Make sure files are owned by the tor user
RUN chown -R debian-tor /etc/tor && \
    chown -R debian-tor /var/lib/tor

# Run tor as a non-root user
USER debian-tor

ENTRYPOINT ["tini", "--", "docker-entrypoint"]
CMD ["tor", "-f", "/etc/tor/torrc"]
