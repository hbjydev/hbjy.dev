data "cloudflare_accounts" "self" {
  name = "kuraudo-io"
}

data "cloudflare_zone" "self" {
  name = "hbjy.dev"
}
