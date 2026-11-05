# Stage 1: Build Flutter Web application
FROM ghcr.io/cirruslabs/flutter:3.24.5 AS build-env

WORKDIR /app

# Copy dependency configs
COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get

# Copy source code and build web bundle
COPY . .
RUN flutter build web --release

# Stage 2: Serve using high-performance Nginx Linux container
FROM nginx:alpine

COPY --from=build-env /app/build/web /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]

