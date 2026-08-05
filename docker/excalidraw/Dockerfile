FROM node:24-slim

WORKDIR /app

COPY ./excalidraw .

RUN yarn install --frozen-lockfile

ARG VITE_APP_WS_SERVER_URL=https://oss-collab.excalidraw.com

RUN NODE_OPTIONS=--max-old-space-size=2048 yarn build:app:docker

USER node

EXPOSE 8080

CMD ["yarn", "http-server", "./excalidraw-app/build"]
