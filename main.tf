resource "helm_release" "release" {
  depends_on = [var.module_depends_on]
  count      = var.enabled ? 1 : 0
  chart      = local.chart
  namespace  = local.namespace
  name       = local.name
  version    = local.version
  repository = local.repository

  dynamic "set" {
    for_each = var.settings
    content {
      name  = set.key
      value = set.value
    }
  }
}

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
}

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
      "helm" = {
        "parameters" = values({
          for key, value in local.conf :
          key => {
            "name"  = key
            "value" = tostring(value)
          }
        })
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
