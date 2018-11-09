FROM golang:1.10-alpine AS go-builder

ENV DOCKER_GEN_VERSION=0.7.4

# Install build dependencies for docker-gen
RUN apk add --update \
        curl \
        gcc \
        git \
        make \
        musl-dev

# Build docker-gen
RUN go get github.com/jwilder/docker-gen \
    && cd /go/src/github.com/jwilder/docker-gen \
    && git checkout $DOCKER_GEN_VERSION \
    && make get-deps \
    && make all


FROM alpine:latest
LABEL maintainer="Jason Wilder <mail@jasonwilder.com>"

ENV DOCKER_HOST unix:///tmp/docker.sock

RUN apk -U add openssl

COPY --from=go-builder /go/src/github.com/jwilder/docker-gen/docker-gen /usr/local/bin

ENTRYPOINT ["/usr/local/bin/docker-gen"]
