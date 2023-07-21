resource "local_file" "this" {
  count    = local.argocd_enabled
  content  = yamlencode(local.app)
  filename = "${var.argocd.path}/${local.name}.yaml"
}

locals {
  argocd_enabled = length(var.argocd) > 0 ? 1 : 0
  namespace      = var.namespace
  name           = var.internal ? "aws-node-termination-handler" : "aws-node-termination-handler"
  repository     = "https://aws.github.io/eks-charts/"
  chart          = "aws-node-termination-handler"
  version        = var.chart_version

  app = {
    "apiVersion" = "argoproj.io/v1alpha1"
    "kind"       = "Application"
    "metadata" = {
      "name"      = local.name
      "namespace" = var.argocd.namespace
    }
    "spec" = {
      "destination" = {
        "namespace" = local.namespace
        "server"    = "https://kubernetes.default.svc"
      }
      "project" = "default"
      "source" = {
        "repoURL"        = local.repository
        "targetRevision" = local.version
        "chart"          = local.chart
      }
    }
    "syncPolicy" = {
      "automated" = {
        "prune"    = true
        "selfHeal" = true
      }
    }
    "syncOptions" = {
      "createNamespace" = true
    }
  }
}
