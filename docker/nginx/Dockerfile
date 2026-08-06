FROM nginx:1.30-alpine

COPY ./docker/nginx/default.conf /etc/nginx/conf.d/default.conf

EXPOSE 80
EXPOSE 443

CMD ["nginx", "-g", "daemon off;"]
