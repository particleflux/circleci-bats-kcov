FROM debian:bullseye-slim AS builder

ENV KCOV_VERSION 38
ENV BATS_VERSION 1.2.1

RUN apt-get update && \
    apt-get install -y \
        binutils-dev \
        build-essential \
        cmake \
        curl \
        git \
        libcurl4-openssl-dev \
        libdw-dev \
        libiberty-dev \
        libssl-dev \
        ninja-build \
        python3 \
        zlib1g-dev \
        ;

# kcov
RUN curl -sSL "https://github.com/SimonKagstrom/kcov/archive/refs/tags/${KCOV_VERSION}.tar.gz" \
    | tar -C '/tmp' -xzv \
    && cd "/tmp/kcov-${KCOV_VERSION}" \
    && mkdir build \
    && cd build \
    && cmake -G 'Ninja' .. \
    && cmake --build . \
    && cmake --build . --target install

# bats
RUN curl -sSL "https://github.com/bats-core/bats-core/archive/v$BATS_VERSION.tar.gz" \
      | tar -C '/tmp' -xzv \
    && cd "/tmp/bats-core-$BATS_VERSION" \
    && ./install.sh /usr/local \
    && bats --version




FROM debian:bullseye-slim

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    'curl=7.*' 'git=1:2.*' 'jq=1.*' 'openssh-client=1:8.*' 'sudo=1.*' 'ca-certificates' \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && useradd -ms /bin/bash circleci \
    && echo 'circleci ALL=NOPASSWD: ALL' >> /etc/sudoers.d/50-circleci

COPY --from=builder /usr/local/bin/kcov* /usr/local/bin/
COPY --from=builder /usr/local/share/doc/kcov /usr/local/share/doc/kcov
COPY --from=builder /usr/local/bin/bats* /usr/local/bin/
COPY --from=builder /usr/local/libexec/bats-core /usr/local/libexec/bats-core

USER circleci
