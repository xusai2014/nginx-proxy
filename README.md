## HTTPS 域名泛解析

[certbot](https://eff-certbot.readthedocs.io/en/stable/using.html#nginx) 证书生成

Mac OS
```shell
brew install certbot
# Obtain and install a certificate:
certbot

# Obtain a certificate but don't install it:
certbot certonly

# You may specify multiple domains with -d and obtain and
# install different certificates by running Certbot multiple times:
certbot certonly -d example.com -d www.example.com
certbot certonly -d app.example.com -d api.example.com
```




certbot certonly --manual --preferred-challenges http -d *.chejj.cc --server https://acme-staging-v02.api.letsencrypt.org/directory --config-dir ./https-file --work-dir ./https-file --logs-dir ./https-file

配置TXT DNS解析记录