output "repo_name" {
  value = github_repository.gitops.name
}

output "deploy_ssh_public_key" {
  value = tls_private_key.deploy-key.public_key_openssh
}
