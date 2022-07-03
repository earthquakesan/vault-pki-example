resource "vault_mount" "root" {
  type                      = "pki"
  path                      = "pki"
  default_lease_ttl_seconds = 8640000
  max_lease_ttl_seconds     = 8640000
}

resource "vault_pki_secret_backend_root_cert" "root-cert" {
  depends_on           = [vault_mount.root]
  backend              = vault_mount.root.path
  type                 = "internal"
  common_name          = "Root CA"
  ttl                  = "315360000"
  format               = "pem"
  private_key_format   = "der"
  key_type             = "rsa"
  key_bits             = 4096
  exclude_cn_from_sans = true
  ou                   = "My OU"
  organization         = "My organization"
}

resource "vault_pki_secret_backend_role" "role" {
  backend        = vault_mount.root.path
  name           = "2022-servers"
  allow_any_name = true
}

resource "vault_pki_secret_backend_config_urls" "example" {
  backend = vault_mount.root.path
  issuing_certificates = [
    "http://localhost:8200/v1/pki/ca",
  ]
  crl_distribution_points = [
    "http://localhost:8200/v1/pki/crl",
  ]
}

resource "vault_mount" "intermediate" {
  path                      = "pki_int"
  type                      = "pki"
  default_lease_ttl_seconds = 8640000
  max_lease_ttl_seconds     = 8640000
}

resource "vault_pki_secret_backend_intermediate_cert_request" "intermediate" {
  depends_on  = [vault_mount.intermediate]
  backend     = vault_mount.intermediate.path
  type        = "internal"
  common_name = "example.com Intermediate Authority"
}

resource "vault_pki_secret_backend_root_sign_intermediate" "intermediate" {
  depends_on           = [vault_pki_secret_backend_intermediate_cert_request.intermediate]
  backend              = vault_mount.root.path
  csr                  = vault_pki_secret_backend_intermediate_cert_request.intermediate.csr
  common_name          = "Intermediate CA"
  exclude_cn_from_sans = true
  ou                   = "My OU"
  organization         = "My organization"
}

resource "vault_pki_secret_backend_intermediate_set_signed" "intermediate" {
  backend     = vault_mount.intermediate.path
  certificate = vault_pki_secret_backend_root_sign_intermediate.intermediate.certificate
}

resource "vault_pki_secret_backend_role" "intermediate" {
  backend          = vault_mount.intermediate.path
  name             = "intermediate"
  ttl              = 3600
  allow_ip_sans    = true
  key_type         = "rsa"
  key_bits         = 4096
  allowed_domains  = ["example.com"]
  allow_subdomains = true
}

resource "vault_pki_secret_backend_cert" "app" {
  depends_on = [vault_pki_secret_backend_role.intermediate]

  backend = vault_mount.intermediate.path
  name    = vault_pki_secret_backend_role.intermediate.name

  common_name = "app.example.com"
}

resource "vault_mount" "certs-kv" {
  path        = "certs"
  type        = "kv"
  options     = { version = "2" }
  description = "KV Version 2 secret engine mount"
}

resource "vault_kv_secret_v2" "secret" {
  mount = vault_mount.certs-kv.path
  name  = "secret"
  cas   = 1
  data_json = jsonencode(
    {
      key        = vault_pki_secret_backend_cert.app.private_key,
      cert       = vault_pki_secret_backend_cert.app.certificate,
      expiration = vault_pki_secret_backend_cert.app.expiration
    }
  )
}
