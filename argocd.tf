# ============================================
# ArgoCD (via Helm)
# ============================================

resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = "9.4.15"
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

# ============================================
# Ingress NGINX (via Helm)
# ============================================

resource "helm_release" "ingress_nginx" {
  name             = "ingress-nginx"
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  version          = "4.12.1"
  namespace        = "ingress-nginx"
  create_namespace = true

  set {
    name  = "controller.service.type"
    value = "LoadBalancer"
  }

  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/azure-load-balancer-health-probe-request-path"
    value = "/healthz"
  }

  set {
    name  = "controller.admissionWebhooks.enabled"
    value = "false"
  }

  depends_on = [azurerm_kubernetes_cluster.aks]
}
