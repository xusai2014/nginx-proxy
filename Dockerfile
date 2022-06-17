FROM nginx:1.21.5-alpine
MAINTAINER xusai521@gmail.com
USER root

COPY nginx.conf /etc/nginx
COPY scripts /etc/nginx/scripts
COPY html /usr/share/nginx/html

ENV TZ Asia/Shanghai
CMD ["nginx", "-g", "daemon off;"]

