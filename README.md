# one-for-all-chart

Универсальный Helm chart (имя чарта — `ofa`) для развёртывания типовых
приложений в Kubernetes.

Чарт умеет деплоить `Deployment`, `StatefulSet`, `Job`, а также несколько
приложений одним релизом через секцию `apps[]`.

## Установка

Чарт публикуется через GitHub Pages (ветка `gh-pages`) с помощью
`helm/chart-releaser-action`.

```bash
helm repo add ofa https://akopyanlabs.github.io/one-for-all-chart
helm repo update
helm upgrade --install my-app ofa/ofa -n my-namespace --create-namespace -f values.yaml
```

## Быстрая проверка локально

```bash
git clone https://github.com/akopyanlabs/one-for-all-chart.git
cd one-for-all-chart/charts/one-for-all
helm lint .
helm template my-app .
```

## Возможности

- Режимы деплоя: `Deployment` (по умолчанию), `StatefulSet`, `Job`
- Multi-app: несколько приложений одним релизом (`apps[]`)
- Multi-service: несколько `Service` на один workload (`services[]`)
- Сеть: `Service`, `Ingress`, `NetworkPolicy`
- Хранилище: `PersistentVolumeClaim` (с пропуском уже существующих), `extraVolumes`/`extraVolumeMounts`, `ConfigMap`
- Конфигурация: `env`, `secrets` (→ Secret + `secretKeyRef`), `ConfigMap` с mount/subPath
- Пробы: `livenessProbe`, `readinessProbe`
- Безопасность: `securityContext` (pod/container), `serviceAccount`, `imagePullSecrets`
- Планирование: `nodeSelector`, `affinity`, `tolerations`, `strategy`
- Аннотации-интеграции: Prometheus scrape, Istio inject, Fluentbit parser

## Документация

Подробное руководство по `values.yaml` и примеры для каждого режима — в
[`charts/one-for-all/README.md`](charts/one-for-all/README.md).
