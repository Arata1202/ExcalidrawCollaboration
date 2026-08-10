FROM nginx:1.30.4-alpine-slim

COPY ./15-auth-request.envsh /docker-entrypoint.d/15-auth-request.envsh
COPY ./default.conf.template /etc/nginx/templates/default.conf.template
