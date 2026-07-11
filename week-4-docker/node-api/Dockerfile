# ---- Simple single-stage Dockerfile ----
# Build:  docker build -t node-api .
# Run:    docker run -d -p 3000:3000 --name api node-api

FROM node:20-alpine

# where the app lives inside the image
WORKDIR /app

# copy dependency manifests FIRST so this layer caches (see the session notes)
COPY package*.json ./
RUN npm install --omit=dev

# now copy the rest of the source
COPY . .

# document the port the app listens on
EXPOSE 3000

# the command that runs when the container starts
CMD ["node", "server.js"]
