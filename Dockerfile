FROM kcov/kcov:38

ENV BATS_VERSION 1.2.1

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    'curl=7.64*' 'git=1:2.20*' 'jq=1.5*' 'openssh-client=1:7.*' 'sudo=1.8*' \
    && rm -rf /var/lib/apt/lists/* \
    && useradd -ms /bin/bash circleci \
    && echo 'circleci ALL=NOPASSWD: ALL' >> /etc/sudoers.d/50-circleci \
    # install bats
    && curl -sSL "https://github.com/bats-core/bats-core/archive/v$BATS_VERSION.tar.gz" \
      | tar -C '/tmp' -xzv \
    && cd "/tmp/bats-core-$BATS_VERSION" \
    && ./install.sh /usr/local \
    && bats --version \
    && rm -rf "/tmp/$BATS_VERSION"

USER circleci
