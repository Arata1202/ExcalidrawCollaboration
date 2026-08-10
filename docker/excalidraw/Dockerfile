FROM --platform=${BUILDPLATFORM} node:24.18.0 AS build

WORKDIR /opt/node_app

COPY package.json yarn.lock .npmrc ./
COPY excalidraw-app/package.json ./excalidraw-app/
COPY packages/common/package.json ./packages/common/
COPY packages/element/package.json ./packages/element/
COPY packages/excalidraw/package.json ./packages/excalidraw/
COPY packages/fractional-indexing/package.json ./packages/fractional-indexing/
COPY packages/laser-pointer/package.json ./packages/laser-pointer/
COPY packages/math/package.json ./packages/math/
COPY packages/utils/package.json ./packages/utils/

# do not ignore optional dependencies:
# Error: Cannot find module @rollup/rollup-linux-x64-gnu
RUN --mount=type=cache,target=/root/.cache/yarn \
    npm_config_target_arch=${TARGETARCH} yarn --frozen-lockfile --network-timeout 600000

COPY . .

ARG NODE_ENV=production
ARG VITE_APP_WS_SERVER_URL

RUN npm_config_target_arch=${TARGETARCH} yarn build:app:docker

FROM nginx:1.30.4-alpine-slim

COPY --from=build /opt/node_app/excalidraw-app/build /usr/share/nginx/html

HEALTHCHECK CMD wget -q -O /dev/null http://localhost || exit 1
