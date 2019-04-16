# Build stage
FROM fpco/stack-build:lts-13.17 as builder
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
FROM fpco/stack-run:lts
MAINTAINER Pat Brisbin <pbrisbin@gmail.com>

ENV LANG en_US.UTF-8

RUN mkdir -p /app
WORKDIR /app
COPY wordlist /app/wordlist
COPY --from=builder /root/.local/bin/passphrase-me /app/passphrase-me

CMD ["/app/passphrase-me"]
