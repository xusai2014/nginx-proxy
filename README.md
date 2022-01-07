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



[泛解析配置](https://eff-certbot.readthedocs.io/en/stable/using.html#certbot-commands)
```shell
certbot certonly --manual --preferred-challenges=dns-01 -d *.chejj.cc --server https://acme-v02.api.letsencrypt.org/directory --config-dir ./https-file --work-dir ./https-file --logs-dir ./https-file

```

配置TXT DNS解析记录


HTTPS Verify
https://www.sslshopper.com/ssl-checker.html#hostname=www.chejj.cc

## 排查问题
扫描端口是否监听

```shell
netstat -nltp | grep
``` 
80 命令，查看80端口是否已经被正常监听

```shell
systemctl stop firewalld.service
```

防火墙管理

yum -y install iptables-services

```shell
iptables -A INPUT -p tcp --dport 6666 -j ACCEPT 
```
openssl dhparam -out dhparam.pem 2048

https://www.ssllabs.com/ssltest/analyze.html?d=www.chejj.cc


[OCSP](http://cooolin.com/scinet/2020/07/16/ocsp-stapling-nginx.html)

获取OCSP验证URL
```shell
openssl x509 -noout -ocsp_uri -in cert.pem
```
发起一个OCSP验证请求
```shell
openssl ocsp -issuer chain.pem -cert cert.pem -verify_other chain.pem -header "Host=stg-r3.o.lencr.org" -text -url http://stg-r3.o.lencr.org
```
根据上面URL生成stapling file
```shell
openssl ocsp -no_nonce -respout ./cen2.pw.der -verify_other chain.pem -issuer ./chain.pem -cert ./cert.pem -header "HOST=stg-r3.o.lencr.org" -url http://stg-r3.o.lencr.org
```


openssl s_client -connect www.chejj.cc:443 -tls1 -tlsextdebug -status < /dev/null 2>&1 | awk '{ print $0 }'