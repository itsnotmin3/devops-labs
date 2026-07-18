# Single stage on purpose: this app has ZERO dependencies, so there is no
# node_modules to install or copy — which keeps the pipeline's docker build
# fast and impossible to break. (For a multi-stage build with real deps, see
# the Week 4 labs and ../../jenkins/app.)
FROM node:20-alpine
WORKDIR /app

# Never run as root in a container.
RUN addgroup -S app && adduser -S app -G app

COPY server.js ./
USER app

EXPOSE 3000
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s \
  CMD wget -qO- http://localhost:3000/health || exit 1
CMD ["node", "server.js"]
