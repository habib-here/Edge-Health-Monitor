FROM ubuntu:22.04

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
    netcat-openbsd coreutils gawk \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY receiver.sh /app/receiver.sh
COPY analyze.sh /app/analyze.sh
RUN chmod +x /app/*.sh

VOLUME ["/data"]

ENTRYPOINT ["/app/receiver.sh"]
