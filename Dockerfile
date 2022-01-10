FROM nginx:1.21.5-alpine
MAINTAINER xusai521@gmail.com
USER root

COPY . /etc/nginx


CMD ["nginx", "-g", "daemon off;"]

