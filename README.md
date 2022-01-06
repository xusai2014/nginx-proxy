## HTTPS 域名泛解析

[certbot](https://eff-certbot.readthedocs.io/en/stable/using.html#nginx) 证书生成

certbot certonly --manual --preferred-challenges http -d *.chejj.cc --server https://acme-staging-v02.api.letsencrypt.org/directory --config-dir ./https-file --work-dir ./https-file --logs-dir ./https-file

配置TXT DNS解析记录