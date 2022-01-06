# bin/bash!

\cp -rf nginx.conf /etc/nginx/nginx.conf #强制覆盖
rm -rf /etc/nginx/scripts
\cp -r scripts /etc/nginx/scripts #强制覆盖
nginx -s reload
