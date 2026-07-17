# Jenkins + the Docker CLI + Node.
#
# The stock jenkins/jenkins image has no docker binary and no node, so a
# pipeline that runs `docker build` or `npm ci` fails with "not found".
# Session 20 makes the point that on a self-hosted controller, YOU are
# responsible for what is installed on it. This Dockerfile is that
# responsibility, written down.

FROM jenkins/jenkins:lts-jdk17

# Everything below needs root; we drop back to `jenkins` at the end.
USER root

# --- Docker CLI (client only — it talks to the host's daemon via the socket) ---
RUN apt-get update && apt-get install -y --no-install-recommends \
        ca-certificates curl gnupg \
    && install -m 0755 -d /etc/apt/keyrings \
    && curl -fsSL https://download.docker.com/linux/debian/gpg \
        | gpg --dearmor -o /etc/apt/keyrings/docker.gpg \
    && chmod a+r /etc/apt/keyrings/docker.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
        https://download.docker.com/linux/debian $(. /etc/os-release && echo "$VERSION_CODENAME") stable" \
        > /etc/apt/sources.list.d/docker.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends docker-ce-cli \
    && rm -rf /var/lib/apt/lists/*

# --- Node 20, so the CI pipelines have something to build ---
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y --no-install-recommends nodejs \
    && rm -rf /var/lib/apt/lists/*

# The jenkins user must be able to read the mounted docker socket.
# 988 is the usual docker group id on Ubuntu; if `docker build` fails in a
# pipeline with "permission denied ... /var/run/docker.sock", run
#   getent group docker | cut -d: -f3
# on the HOST and rebuild with --build-arg DOCKER_GID=<that number>.
ARG DOCKER_GID=988
RUN groupadd -g ${DOCKER_GID} docker-host || true \
    && usermod -aG ${DOCKER_GID} jenkins

# Pre-install the plugins the labs need, so nobody sits through the wizard
# picking them by hand.
COPY plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN jenkins-plugin-cli --plugin-file /usr/share/jenkins/ref/plugins.txt

USER jenkins
