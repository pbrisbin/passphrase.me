# Build stage
FROM fpco/stack-build-small:lts-13.17 as builder
MAINTAINER Pat Brisbin <pbrisbin@gmail.com>

ENV LANG en_US.UTF-8
ENV PATH /root/.local/bin:$PATH

RUN mkdir -p /src
WORKDIR /src

COPY stack.yaml /src/
RUN stack setup

COPY package.yaml /src/
RUN stack install --dependencies-only

COPY app /src/app
COPY src /src/src
COPY LICENSE /src/

RUN stack install

# Runtime
FROM ubuntu:18.04
MAINTAINER Pat Brisbin <pbrisbin@gmail.com>
ENV DEBIAN_FRONTEND=noninteractive LANG=C.UTF-8 LC_ALL=C.UTF-8
RUN \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    ca-certificates \
    gcc \
    git \
    locales \
    netbase && \
  locale-gen en_US.UTF-8 && \
  rm -rf /var/lib/apt/lists/*

RUN mkdir -p /app
WORKDIR /app
COPY wordlist /app/wordlist
COPY --from=builder /root/.local/bin/passphrase-me /app/passphrase-me

CMD ["/app/passphrase-me"]
