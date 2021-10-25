# Cetbot

Certbot uses LetsEncrypt to create a free 90 day SSL certificate which can be used for many purposes. This is not production worthy in most cases, but can be used in lower environments or while waiting for the SSL cert to be purchased.

More information about Certbot can be found here: <https://certbot.eff.org/>

When using Ubuntu, you can follow these steps to create a SSL cert.

```bash
# Install Certbot
apt install certbot

# Verify installation and version
certbot --version

# run certbot to create SSL cert using DNS challenge
 certbot -d *.example.com --manual --preferred-challenges dns certonly

 # This will output a TXT record value which must be added to DNS for verification
```

Once complete, you will have a new directory in /etc/letsencrypt/live for your domain. This will contain the cert, private key, signing chain, and full chain. You can create a PFX with the private key, cert, and full chain using the following command:

```bash
openssl pkcs12 -export -out bundle.pfx -inkey privkey.pem -in cert.pem -in fullchain.pem

# provide a secure password as this will contain the private key
```
