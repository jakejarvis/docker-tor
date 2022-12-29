# 🧅 docker-tor

A _very_ simple Docker image that runs the Tor daemon.

> ⚠️ This image is designed for running hidden services, **not** for using Tor on your desktop via a SOCKS proxy, etc. You can still do this — there's nothing special about the Tor binary here — but there are plenty of [other Docker images](https://hub.docker.com/r/peterdavehello/tor-socks-proxy/) better suited for this use case!

## Usage

### CLI

```bash
# create a volume to persist Tor data between container restarts
docker volume create tor-data

# start a Tor container
docker run --rm \
  --name tor \
  --volume tor-data:/var/lib/tor/ \
  --volume ~/my-tor-stuff/torrc:/etc/tor/torrc:ro \
  jakejarvis/tor:latest

# optional: copy existing keys and hostname to volume (restart Tor container afterwards)
docker cp ~/my-tor-stuff/keys/. tor:/var/lib/tor/hidden_service/
```

### `docker-compose.yml`

Example of Tor in front of an nginx web server to run a hidden service:

```yml
version: "3.9"

services:
  tor:
    image: jakejarvis/tor:latest
    restart: unless-stopped
    volumes:
      - tor-data:/var/lib/tor/
      - ./torrc:/etc/tor/torrc:ro
    depends_on:
      - web

  web:
    image: ubuntu/nginx:latest
    restart: unless-stopped
    volumes:
      - ./my_website:/var/www/html
      - ./nginx.conf:/etc/nginx/nginx.conf

volumes:
  tor-data:
```

### Starting a new hidden service

If you don't copy/mount existing keys and a hostname to `/var/lib/tor/hidden_service/` (highly recommended, see next section!) Tor will automatically generate them along with a random `.onion` domain. To see this domain, run:

```sh
docker exec <container id> cat /var/lib/tor/hidden_service/hostname
```

You should be able to visit this `.onion` address immediately in the [Tor Browser](https://www.torproject.org/download/)!

### Using existing Tor config/keys

Simply mounting an existing `torrc` configuration and a folder of public/private keys to the container will tell it exactly how to behave on next start.

```sh
docker cp ~/my-tor-stuff/keys/. <container id>:/var/lib/tor/hidden_service/
```

A default `/etc/tor/torrc` file (see [`torrc.default`](torrc.default)) is already in the image, with a hidden service (whose keys are in `/var/lib/tor/hidden_service`) pointing to a container/server named `web` on port 80 (`http://web:80`).

To override any of this, create your own `torrc` file and mount it to `/etc/tor/torrc` (see above).

## Examples

- [jarvis2i2vp4j4tbxjogsnqdemnte5xhzyi7hziiyzxwge3hzmh57zad.onion](http://jarvis2i2vp4j4tbxjogsnqdemnte5xhzyi7hziiyzxwge3hzmh57zad.onion): A mirror of my clearnet website at [jarv.is](https://jarv.is/)

## License

[MIT](LICENSE)
