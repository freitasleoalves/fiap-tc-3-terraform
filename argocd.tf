# ============================================
# ArgoCD (via Helm)
# ============================================

resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = "7.8.13"
  namespace        = "argocd"
  create_namespace = true

  set {
    name  = "server.service.type"
    value = "LoadBalancer"
  }

  set {
    name  = "configs.repositories.gitops-repo.url"
    value = "https://github.com/freitasleoalves/fiap-tc-3-gitops.git"
  }

  set {
    name  = "configs.repositories.gitops-repo.type"
    value = "git"
  }

  set {
    name  = "configs.repositories.gitops-repo.username"
    value = "freitasleoalves"
  }

  set_sensitive {
    name  = "configs.repositories.gitops-repo.password"
    value = var.argocd_github_token
  }

  set {
    name  = "configs.params.kustomize\\.buildOptions"
    value = "--enable-helm"
  }

  depends_on = [azurerm_kubernetes_cluster.aks]
}
