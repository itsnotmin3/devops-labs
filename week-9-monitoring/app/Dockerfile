FROM node:20-alpine
WORKDIR /app

# Install deps first so this layer caches between rebuilds.
COPY package.json ./
RUN npm install --omit=dev

COPY server.js ./

# Never run as root in a container.
USER node

EXPOSE 3000
CMD ["node", "server.js"]
