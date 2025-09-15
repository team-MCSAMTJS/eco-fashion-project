resource "helm_release" "argocd" {
  name       = "argocd"
  namespace  = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = "5.46.6"  # latest stable version as of writing

  create_namespace = true

  values = [
    file("${path.module}/argocd-values.yaml")
  ]
}