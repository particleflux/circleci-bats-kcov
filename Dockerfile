FROM kcov/kcov:38

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    'bats=0.4.0*' 'curl=7.64*' 'git=1:2.20*' 'jq=1.5*' 'openssh-client=1:7.*' 'sudo=1.8*' \
    && rm -rf /var/lib/apt/lists/* \
    && useradd -ms /bin/bash circleci \
    && echo 'circleci ALL=NOPASSWD: ALL' >> /etc/sudoers.d/50-circleci

USER circleci
