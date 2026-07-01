# syntax=docker/dockerfile:1.7

FROM --platform=${BUILDPLATFORM} node:24@sha256:8530f76a96d88820d288761f022e318970dda93d01536919fbc16076b7983e63 AS build

ARG TARGETARCH

WORKDIR /opt/node_app

COPY excalidraw/ .

# Do not ignore optional dependencies:
# Error: Cannot find module @rollup/rollup-linux-x64-gnu
RUN --mount=type=cache,target=/root/.cache/yarn \
    npm_config_target_arch=${TARGETARCH} yarn --frozen-lockfile --network-timeout 600000

ARG NODE_ENV=production
ARG NODE_OPTIONS=--max-old-space-size=2048
ARG VITE_APP_WS_SERVER_URL=https://oss-collab.excalidraw.com

ENV NODE_ENV=${NODE_ENV}
ENV NODE_OPTIONS=${NODE_OPTIONS}
ENV VITE_APP_WS_SERVER_URL=${VITE_APP_WS_SERVER_URL}

RUN npm_config_target_arch=${TARGETARCH} yarn build:app:docker

FROM nginx:stable-alpine-slim@sha256:2c605dbeab79a6b2a63340474fe58119d0ef95bdc4b1f41df0aa689659b3d13b

COPY --from=build /opt/node_app/excalidraw-app/build /usr/share/nginx/html

HEALTHCHECK CMD wget -q -O /dev/null http://localhost || exit 1
