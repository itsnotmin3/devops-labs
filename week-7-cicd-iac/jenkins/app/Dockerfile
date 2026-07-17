# Multi-stage, same pattern as the Week 4 labs.
FROM node:20-alpine AS base
WORKDIR /app
COPY package*.json ./
RUN npm ci --omit=dev || npm install --omit=dev

FROM node:20-alpine
WORKDIR /app
# Never run as root in a container.
RUN addgroup -S app && adduser -S app -G app
COPY --from=base /app/node_modules ./node_modules
COPY server.js ./
USER app
EXPOSE 3000
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s \
  CMD wget -qO- http://localhost:3000/health || exit 1
CMD ["node", "server.js"]
