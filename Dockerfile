FROM ubuntu:22.04 AS build

ARG FLUTTER_VERSION=3.41.0
ENV DEBIAN_FRONTEND=noninteractive
ENV TAR_OPTIONS="--no-same-owner"
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates curl git unzip xz-utils libglu1-mesa \
    && rm -rf /var/lib/apt/lists/*
RUN git clone --depth 1 --branch "${FLUTTER_VERSION}" \
    https://github.com/flutter/flutter.git /opt/flutter
ENV PATH="/opt/flutter/bin:${PATH}"
RUN flutter config --no-analytics --enable-web \
    && flutter precache --web

WORKDIR /app
COPY pubspec.* ./
RUN flutter pub get
COPY . .
RUN flutter build web --release --no-pub

FROM nginx:stable-alpine AS runtime
ENV PORT=8080
COPY docker/default.conf.template /etc/nginx/templates/default.conf.template
COPY --from=build /app/build/web /usr/share/nginx/html
COPY --from=build /app/build/web/index.html /opt/rushd-index.html
COPY docker/15-configure-maps.sh /docker-entrypoint.d/15-configure-maps.sh
RUN chmod +x /docker-entrypoint.d/15-configure-maps.sh
EXPOSE 8080
