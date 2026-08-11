FROM node:24.18.0-alpine

WORKDIR /opt/node_app

COPY package.json yarn.lock ./

RUN --mount=type=cache,target=/root/.cache/yarn \
    yarn --frozen-lockfile --network-timeout 600000

COPY tsconfig.json ./
COPY src ./src

RUN yarn build

ENV NODE_ENV=production

EXPOSE 80

HEALTHCHECK CMD wget -q -O /dev/null http://localhost || exit 1

CMD ["node", "dist/index.js"]
