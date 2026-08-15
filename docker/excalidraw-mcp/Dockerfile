FROM node:24.18.0-bookworm-slim AS build

WORKDIR /opt/node_app

RUN corepack enable

COPY package.json pnpm-lock.yaml .npmrc ./
COPY scripts ./scripts

RUN --mount=type=cache,target=/root/.local/share/pnpm/store \
    pnpm install --frozen-lockfile

COPY . .

RUN pnpm build

FROM node:24.18.0-bookworm-slim

WORKDIR /opt/node_app

ENV NODE_ENV=production

COPY --from=build /opt/node_app/dist /opt/node_app/dist

HEALTHCHECK CMD node -e "fetch('http://127.0.0.1:3001/mcp', { headers: { Accept: 'application/json, text/event-stream' } }).then((response) => process.exit(response.status < 500 ? 0 : 1)).catch(() => process.exit(1))"

CMD ["node", "dist/index.js"]
