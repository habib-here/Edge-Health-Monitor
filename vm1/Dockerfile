FROM ubuntu:22.04

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
    procps coreutils iproute2 netcat-openbsd bc gawk \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY healthcheck.sh /app/healthcheck.sh
RUN chmod +x /app/*.sh

VOLUME ["/data"]

ENTRYPOINT ["/app/healthcheck.sh"]