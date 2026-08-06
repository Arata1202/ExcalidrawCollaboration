FROM node:24-slim

WORKDIR /excalidraw

COPY . .

RUN yarn install --frozen-lockfile

ARG VITE_APP_WS_SERVER_URL

RUN yarn build:app:docker

EXPOSE 8080

CMD ["yarn", "http-server", "./excalidraw-app/build"]
