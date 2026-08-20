# Monitoring K3s

Klaster K3s jest monitorowany przez `kube-prometheus-stack` zainstalowanyprzez Helm.

W skład zestawu wchodzą:

```
- Prometheus
- Grafana
- Alertmanager
- node-exporter
- kube-state-metrics
- Prometheus Operator
- gotowe dashboardy Kubernetes
```

Prometheus zbiera informacje o nodach, użyciu CPU i RAM, podach, restartach kontenerów, Deploymentach, wolumenach, Kubernetes API, kubelecie i CoreDNS.

## Ustawienia dla K3s

K3s uruchamia kilka elementów control plane w jednym procesie. Z tego powodu wyłączone są standardowe monitory dla osobnego:

```
- etcd
- kube-controller-manager
- kube-scheduler
- kube-proxy
```

Pozostają monitory Kubernetes API, kubeleta, CoreDNS, node-exportera i kube-state-metrics.

## Retencja i dyski

| Komponent | Retencja | PVC |
|---|---|---:|
| Prometheus | 15 dni, około 15 GB | 20 GiB |
| Alertmanager | 120 godzin | 2 GiB |
| Grafana | dane i ustawienia | 5 GiB |

PVC korzystają ze StorageClass `local-path`. Dane są więc zapisane na nodzie, na którym powstał dany wolumen.

## Grafana

Grafana jest wystawiona przez NGINX Ingress i HTTPS. Prometheus jest ustawiony jako domyślne źródło danych, a razem ze stosem instalowane są dashboardy Kubernetes.

## Zabbix a Prometheus

Zabbix zbiera dane z systemów Windows i Linux przez agenty. Prometheus zbiera metryki klastra K3s i obiektów Kubernetes. Oba systemy działają obok siebie, ale mają inny zakres.
