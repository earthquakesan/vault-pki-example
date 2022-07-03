# Vault PKI Configuration

The example is taken from: https://learn.hashicorp.com/tutorials/vault/pki-engine?in=vault/secrets-management

Start the vault server (requires docker):

```
make start
```

Connect to the running server:

```
make connect
```

Provision backends and the certificates (will be saved under certs/ path):

```
make terraform
```

To navigate to vault open http://localhost:8200 in the browser.

WARNING: the cert and key are stored in the terraform state (!) Make sure to encrypt it and do not allow users to access the terraform state.

# Notes

The certificate monitoring needs to be configured externally, for example with prometheus:

* https://schh.medium.com/prometheus-continuous-monitoring-of-ssl-expiration-8406cf4df5a0

The certificates are available under paths such as (do not require auth):

* http://localhost:8200/v1/pki_int/cert/40:dd:cc:ed:26:47:02:86:ab:fb:c8:ce:83:08:b4:9c:24:19:a9:2c

# Manual Certificate Generation

To generate CA and the certificates by hand, see for example:

* https://docs.microsoft.com/en-us/azure/application-gateway/self-signed-certificates

