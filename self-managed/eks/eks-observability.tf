# Create observability namespace
resource "kubernetes_namespace" "observability" {
  metadata {
    name = "observability"
  }

  # Ensure the EKS cluster (and its RBAC changes) is created before creating this namespace
  depends_on = [module.eks]
}

# Create prometheus deployment
resource "helm_release" "prometheus" {
  name       = "prometheus"
  repository = "https://prometheus-community.github.io/helm-charts"
  version    = var.prometheus_chart_version
  chart      = "prometheus"
  namespace  = "observability"

  values = [
    templatefile("${path.module}/helm/prometheus.yaml", {})
  ]

  depends_on = [module.eks,
                kubernetes_namespace.observability,
                module.vpc,
                helm_release.consul
                ]
}

# Create grafana deployment
resource "helm_release" "grafana" {
  name       = "grafana"
  repository = "https://grafana.github.io/helm-charts"
  version    = var.grafana_chart_version
  chart      = "grafana"
  namespace  = "observability"

  values = [
    templatefile("${path.module}/helm/grafana.yaml", {})
  ]

  depends_on = [module.eks,
                kubernetes_namespace.observability,
                module.vpc,
                helm_release.consul,
                helm_release.prometheus
                ]
}