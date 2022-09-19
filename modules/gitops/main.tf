resource "github_repository" "gitops" {
  allow_auto_merge       = true
  allow_merge_commit     = true
  allow_rebase_merge     = false
  allow_squash_merge     = false
  delete_branch_on_merge = true
  has_issues             = true
  description            = var.repo_description
  name                   = var.repo_name
  vulnerability_alerts   = true
  topics = [
    "argocd",
    "gitops",
    "kubernetes",
  ]

  lifecycle {
    prevent_destroy = true
  }
}

resource "tls_private_key" "deploy-key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "github_repository_deploy_key" "argocd-deploy-key" {
  repository = github_repository.gitops.name
  title      = "Argo CD GitOps"
  read_only  = true
  key        = tls_private_key.deploy-key.public_key_openssh
}

resource "random_password" "webhook-secret" {
  length = 32
}

resource "github_repository_webhook" "argocd" {
  repository = github_repository.gitops.name
  active     = true

  events = ["push"]

  configuration {
    url          = local.argocd_webhook_url
    content_type = "json"
    secret       = random_password.webhook-secret.result
  }
}

resource "github_actions_secret" "tf_api_token" {
  repository = github_repository.gitops.name

  secret_name     = "TF_API_TOKEN"
  plaintext_value = var.gha_tf_api_token
}


resource "null_resource" "init" {
  triggers = {
    generation = 1
  }

  connection {
    user        = "root"
    host        = var.control_plane_ip
    private_key = var.ssh_private_key
  }

  provisioner "remote-exec" {
    inline = [
      "set -eu",
      "rm -rf /root/init",
    ]
  }

  provisioner "file" {
    source      = "${path.module}/../../init/cloudlab"
    destination = "/root/init"
  }

  provisioner "file" {
    content = templatefile("${path.module}/templates/infrastructure-repository.yaml", {
      ssh_key = tls_private_key.deploy-key.private_key_openssh
    })
    destination = "/root/init/resources/infrastructure-repository.yaml"
  }

  provisioner "file" {
    content = templatefile("${path.module}/templates/bootstrap-store.yaml", {
      op_token       = var.op_token
      op_credentials = var.op_credentials
    })
    destination = "/root/init/resources/bootstrap-store.yaml"
  }

  provisioner "remote-exec" {
    inline = [
      <<-BASH
      kubectl apply --server-side -k init
      if [ $? -eq 0 ]; then
        exit 0
      else
        sleep 10
        kubectl apply --server-side -k init
        exit $?
      fi
      BASH
    ]
  }
}
