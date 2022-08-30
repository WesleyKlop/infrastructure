
resource "github_repository" "infrastructure" {
  allow_auto_merge       = true
  allow_merge_commit     = true
  allow_rebase_merge     = false
  allow_squash_merge     = false
  delete_branch_on_merge = true
  has_issues             = true
  description            = "Server infrastructure in k8s"
  name                   = "infrastructure"
  vulnerability_alerts   = true
  topics = [
    "fluxcd",
    "gitops",
    "kubernetes",
  ]

  lifecycle {
    prevent_destroy = true
  }
}

resource "github_repository_deploy_key" "argocd-deploy-key" {
  repository = github_repository.infrastructure.name
  title      = "Argo CD GitOps"
  read_only  = true
  key        = tls_private_key.deploy-key.public_key_openssh
}

resource "random_password" "webhook-secret" {
  length = 32
}

resource "github_repository_webhook" "argocd" {
  repository = github_repository.infrastructure.name
  active     = true

  events = ["push"]

  configuration {
    url          = "https://argocd-javelin.wesl.io/api/webhook"
    content_type = "json"
    secret       = random_password.webhook-secret.result
  }
}
