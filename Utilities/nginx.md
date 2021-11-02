# Nginx

Gerneral notes for NGINX

## General Support

```bash
# Check status of the service
systemcl status nginx

# Restart the service
systemcl restart nginx

# Check the config and reload nginx
nginx -t && nginx -s reload
```


## General Proxy Config Block

This can be used to proxy traffic behind the NGINX server using the hostname.

```bash
server {
        listen 80;
        server_name app.domain.io;
        location / {
        proxy_set_header        X-Forwarded-For $remote_addr;
        proxy_set_header        Host $http_host;
        proxy_pass              http://10.0.0.4:8080;
        }
}
```

## Adding SSL to Nginx Proxy

Follow this guide for net-new functionality: <https://www.nginx.com/blog/using-free-ssltls-certificates-from-lets-encrypt-with-nginx/>