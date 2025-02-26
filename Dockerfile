FROM debian:bullseye-slim AS builder

# renovate: datasource=github-releases depName=SimonKagstrom/kcov versioning=loose
ENV KCOV_VERSION=v43
# renovate: datasource=github-releases depName=bats-core/bats-core versioning=semver
ENV BATS_VERSION=v1.11.1

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
    && cd "/tmp/kcov-$(echo "$KCOV_VERSION" | tr -d v)" \
    && mkdir build \
    && cd build \
    && cmake -G 'Ninja' .. \
    && cmake --build . \
    && cmake --build . --target install

# bats
RUN curl -sSL "https://github.com/bats-core/bats-core/archive/$BATS_VERSION.tar.gz" \
      | tar -C '/tmp' -xzv \
    && cd "/tmp/bats-core-$(echo "$BATS_VERSION" | tr -d v)" \
    && ./install.sh /usr/local \
    && bats --version




FROM debian:bullseye-slim

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    # generic stuff for CI work
    'curl=7.*' 'git=1:2.*' 'jq=1.*' 'openssh-client=1:8.*' 'sudo=1.*' 'ca-certificates' \
    # kcov runtime requirements
    'binutils=2.*' 'libcurl4=7.*' 'libdw1=0.*' \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && useradd -ms /bin/bash circleci \
    && echo 'circleci ALL=NOPASSWD: ALL' >> /etc/sudoers.d/50-circleci

COPY --from=builder /usr/local/bin/kcov* /usr/local/bin/
COPY --from=builder /usr/local/share/doc/kcov /usr/local/share/doc/kcov
COPY --from=builder /usr/local/bin/bats* /usr/local/bin/
COPY --from=builder /usr/local/libexec/bats-core /usr/local/libexec/bats-core
COPY --from=builder /usr/local/lib/bats-core /usr/local/lib/bats-core

USER circleci
