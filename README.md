## 网络安全

HTTP请求是明文传输且存在中间人抓包、篡改，伪站点冒充等问题，使用HTTPS协议有如下优势：
- 身份认证
- 信息加密
- 完整性校验

加密采用的是混合加密，对称加密、非对称加密。
数字签名采用哈希摘要

#### SSL如何建立连接？
- (client request)  
  - browser向server发送请求，提供随机值1和支持的加密算法列表 
- (server response) 
  - server向client返回随机值2和匹配好的协商加密算法          
- (server response) 
  - server向client二次返回数字证书                        
- (browser CA verify)  
  - browser解析数字证书并验证证书有效性,并生成一个随即值（预主秘钥）。
- (browser generate secrets)
  - 再通过随机值1、随机值2和预主秘钥组装会话秘钥。
  - 然后通过证书的公钥加密会话秘钥。
- (browser request) 
  - 传送加密信息即证书加密后的会话秘钥
- (server verify) 
  - 解密得到随机值1、随机值2和预主秘钥，然后组装会话秘钥，跟客户端会话秘钥相同
- (browser request) 
  - browser通过会话秘钥加密一条消息发送给server，主要验证server是否正常接受browser加密的消息。
- (server response) 
  - 同样服务端也会通过会话秘钥加密一条消息回传给客户端,如果客户端能够正常接受的话表明SSL层连接建立完成了。

HTTPS在传输的过程中会涉及到三个密钥：
- 服务器端的公钥和私钥，用来进行非对称加密 
- 客户端生成的随机密钥，用来进行对称加密




## HTTPS 免费证书配置（包括通配符证书）

如果启用HTTPS基于安全套接层的HTTP协议，需要从证书颁发机构（CA）申请证书。
- letsencrypt是一个免费的CA。
- 获取证书需要证明域名控制权。例如在主机运行[ACME协议](https://datatracker.ietf.org/doc/html/rfc8555)


### 通过ACME客户端来验证域名控制权并颁发证书（推荐使用certbot）

通过[certbot](https://eff-certbot.readthedocs.io/en/stable/using.html#nginx) 证明域名控制权后，方可申请、续期、吊销证书。

- certbot 与 CA 交互生成密钥对（“授权密钥对”）
- certbot证明该域名控制权即域名认证 

（那如何进行域名认证呢？）

- 首先certbot会启动并询问采用什么方式进行域名验证呢？
- CA会提供给客户端多种方式选择，例如 DNS解析、HTTP资源请求
- 选择其中一种验证方式
- CA会查看该域名并要求certbot发起验证请求
- 除要求验证请求之外，CA还会提供一个 nonce（一次性数字）。（目的是让certbot使用私钥对它签名，以证明其对密钥对的控制权）
- Certbot发起验证请求成功后会用私钥（“授权密钥对”）对提供的 nonce（一次性数字）进行签名，并通知CA验证完成
- CA得到验证完成通知后会先进行签名验证，并自行获取验证请求结果

一旦客户端拥有了授权公私钥，那么请求、续期和撤销证书就会变得很简单——只需发送证书管理消息并使用授权私钥对其进行签名。（那如何进行证书颁发呢？）

- certbot创建一个 PKCS#10 证书签名请求（CSR），要求 CA 为指定的公钥颁发已验证控制权域名的证书。
- CSR 中包含公钥及该公钥对应的私钥的签名。
- certbot还使用域名授权私钥签署整个 CSR，以便 Let’s Encrypt CA 知道它已获得授权。
- CA会对授权、私钥两个签名进行验证，一切正常则为该公钥颁发证书并返回给certbot

当 Let’s Encrypt CA 收到请求时，它会验证这两个签名。如果一切正常，CA 将为 CSR 中的公钥颁发 example.com 的证书，并将文件发送回证书管理软件。

服务端向客户端下发的数字证书，加密（CA私钥加密）内容如下：
- 颁发机构
- 过期时间
- 服务端公钥
- 第三方证书认证机构(CA)的签名
- 服务端的域名信息

客户端解析数字证书

- 使用本地配置的权威机构的公钥对证书进行解密得到服务端的公钥和证书的数字签名
- 数字签名经过CA公钥解密得到证书信息摘要
- 然后证书签名的方法计算一下当前证书的信息摘要，与收到的信息摘要作对比，如果一样，表示证书一定是服务器下发的

CentOS
```shell
sudo snap install --classic certbot
# Obtain and install a certificate:
certbot

# Obtain a certificate but don't install it:
certbot certonly

# You may specify multiple domains with -d and obtain and
# install different certificates by running Certbot multiple times:
certbot certonly -d example.com -d www.example.com
certbot certonly -d app.example.com -d api.example.com
```

[泛解析配置](https://eff-certbot.readthedocs.io/en/stable/using.html#certbot-commands) 如下：

选取DNS验证方式
```shell
certbot certonly --manual --preferred-challenges=dns-01 -d *.chejj.cc --server https://acme-v02.api.letsencrypt.org/directory --config-dir ./https-file --work-dir ./https-file --logs-dir ./https-file

```
再次过程只能够配置TXT DNS解析验证,最后生成证书文件。


[HTTPS Verify](https://www.sslshopper.com/ssl-checker.html#hostname=www.chejj.cc)


## 实操中遇到需要排查问题点
查看80端口是否已经被正常监听 （阿里云存在安全组和防火墙软件对相关端口进行开放）
```shell
netstat -nltp | grep 80
```
```shell
systemctl stop firewalld.service
# or
systemctl stop iptables.service
```

或者防火墙管理
```shell
yum -y install iptables-services
iptables -A INPUT -p tcp --dport 6666 -j ACCEPT 
```

[OCSP](http://cooolin.com/scinet/2020/07/16/ocsp-stapling-nginx.html) 在线证书状态协议
OCSP协议的产生是用于在公钥基础设施（PKI）体系中替代证书吊销列表（CRL）来查询数字证书的状态，当用户试图访问一个服务器时，在线证书状态协议发送一个对于证书状态信息的请求。服务器回复一个“有效”、“过期”或“未知”的响应。

获取OCSP验证URL
```shell
openssl x509 -noout -ocsp_uri -in cert.pem
# https://r3.o.lencr.org
```
发起一个OCSP验证请求
```shell
openssl ocsp -issuer chain.pem -cert cert.pem -verify_other chain.pem -header "Host=r3.o.lencr.org" -text -url http://r3.o.lencr.org
```
生成stapling file
```shell
openssl ocsp -no_nonce -respout ./cen2.pw.der -verify_other chain.pem -issuer ./chain.pem -cert ./cert.pem -header "HOST=r3.o.lencr.org" -url http://r3.o.lencr.org
```


openssl s_client -connect www.chejj.cc:443 -tls1 -tlsextdebug -status < /dev/null 2>&1 | awk '{ if ($0 ~ /OCSP response: no response sent/) { print "disabled" } else if ($0 ~ /OCSP Response Status: successful/) { print "enabled" } }'