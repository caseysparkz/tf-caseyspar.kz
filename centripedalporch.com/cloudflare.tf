###############################################################################
# Cloudflare
#

## Locals =====================================================================
locals {
  cloudflare_comment = "Terraform managed."
  cloudflare_zone_id = data.cloudflare_zone.root_domain.id
  dmarc_policy = { #                                                            Parsed to string.
    p     = "reject"
    sp    = "reject"
    adkim = "s"
    aspf  = "s"
    fo    = 1
    pct   = 5
  }
}

## Data =======================================================================
data "cloudflare_zone" "root_domain" { #                                        Root zone.
  name = var.root_domain
}

## Resources ==================================================================
resource "cloudflare_zone_settings_override" "root_zone" { #                    Zone settings.
  zone_id = local.cloudflare_zone_id

  settings {
    always_use_https         = "on"
    automatic_https_rewrites = "on"
    http3                    = "on"
    min_tls_version          = "1.2"
    opportunistic_encryption = "on"
    ssl                      = "flexible"
    tls_1_3                  = "on"
    universal_ssl            = "on"
  }
}


resource "cloudflare_record" "dmarc" { #                                        DMARC policy.
  zone_id         = local.cloudflare_zone_id
  name            = "_dmarc"
  value           = "v=DMARC1;${join("; ", [for k, v in local.dmarc_policy : "${k}=${v}"])}"
  type            = "TXT"
  ttl             = 1
  proxied         = false
  allow_overwrite = true
  comment         = local.cloudflare_comment
}

resource "cloudflare_record" "txt" { #                                          TXT records.
  for_each        = var.txt_records
  zone_id         = local.cloudflare_zone_id
  name            = each.value
  value           = each.key
  type            = "TXT"
  ttl             = 1
  proxied         = false
  allow_overwrite = true
  comment         = local.cloudflare_comment
}

resource "cloudflare_record" "pka" { #                                          PKA records.
  for_each        = var.pka_records
  zone_id         = local.cloudflare_zone_id
  name            = "${each.key}._pka"
  value           = "v=pka1; fpr=${each.value}"
  type            = "TXT"
  ttl             = 1
  proxied         = false
  allow_overwrite = true
  comment         = local.cloudflare_comment
}

resource "cloudflare_turnstile_widget" "captcha" { #                            ReCaptcha.
  account_id = var.cloudflare_account_id
  name       = var.root_domain
  domains    = [var.root_domain]
  mode       = "managed"
}

## Outputs ====================================================================
output "main_cloudflare_zone_root" {
  description = "Zone data for the root Cloudflare DNS zone."
  value       = data.cloudflare_zone.root_domain
}

output "turnstile_site_key" {
  description = "Turnstile site key for root domain."
  value       = cloudflare_turnstile_widget.captcha.id
  sensitive   = false
}

output "turnstile_secret_key" {
  description = "Turnstile secret key for root domain."
  value       = cloudflare_turnstile_widget.captcha.secret
  sensitive   = true
}
