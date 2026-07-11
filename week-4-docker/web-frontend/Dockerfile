# ---- Multi-stage Dockerfile ----
# Build:  docker build -t web-frontend .
# Run:    docker run -d -p 8080:80 --name web web-frontend
#
# Stage 1 uses the big Node image to BUILD.
# Stage 2 keeps ONLY the built files in a tiny nginx image.

# ---- stage 1: build ----
FROM node:20-alpine AS build
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build            # produces /app/dist

# ---- stage 2: the tiny final image ----
FROM nginx:alpine
COPY --from=build /app/dist /usr/share/nginx/html
EXPOSE 80
# nginx runs by default
