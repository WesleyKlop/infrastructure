
resource "github_repository" "infrastructure" {
  allow_auto_merge       = true
  allow_merge_commit     = true
  allow_rebase_merge     = false
  allow_squash_merge     = false
  delete_branch_on_merge = true
  description            = "Server infrastructure in k8s"
  name                   = "infrastructure"
  vulnerability_alerts   = true
  topics = [
    "fluxcd",
    "gitops",
    "kubernetes",
  ]
}

resource "github_repository_deploy_key" "argocd-deploy-key" {
  repository = github_repository.infrastructure.name
  title      = "Argo CD GitOps"
  read_only  = true
  key        = tls_private_key.deploy-key.public_key_openssh
}
