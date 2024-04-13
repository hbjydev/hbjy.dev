resource "cloudflare_web_analytics_site" "self" {
  account_id   = data.cloudflare_accounts.self.accounts[0].id
  zone_tag     = data.cloudflare_zone.self.zone_id
  auto_install = false
}

resource "cloudflare_pages_project" "self" {
  account_id        = data.cloudflare_accounts.self.accounts[0].id
  name              = "hbjydev-blog"
  production_branch = "main"

  source {
    type = "github"
    config {
      owner             = "hbjydev"
      repo_name         = "hbjy.dev"
      production_branch = "main"
      # pr_comments_enabled           = true
      deployments_enabled           = true
      production_deployment_enabled = true
    }
  }

  build_config {
    build_command       = "npm run build"
    destination_dir     = "dist"
    root_dir            = ""
    web_analytics_tag   = cloudflare_web_analytics_site.self.site_tag
    web_analytics_token = cloudflare_web_analytics_site.self.site_token
  }

  deployment_configs {
    preview {
      compatibility_date  = "2022-06-15"
      compatibility_flags = ["nodejs_compat"]
    }

    production {
      compatibility_date  = "2022-06-15"
      compatibility_flags = ["nodejs_compat"]
    }
  }
}
