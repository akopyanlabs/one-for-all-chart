# one-for-all (chart name: `ofa`)

Универсальный Helm chart для развёртывания типовых приложений в Kubernetes.
Один чарт покрывает большинство задач: stateless-сервисы, stateful-приложения,
разовые Job'ы и платформы из нескольких приложений одним релизом.

## TL;DR

```bash
helm repo add ofa https://akopyanlabs.github.io/one-for-all-chart
helm repo update
helm upgrade --install my-app ofa/ofa \
  -n my-namespace --create-namespace \
  --set image.repository=nginx \
  --set image.tag=1.27.0
```

## Введение

Чарт умеет создавать:

- `Deployment` (по умолчанию) или `StatefulSet` — переключается через `global.deploymentType`
- `Job` — через секцию `job`
- несколько приложений одним релизом — через `apps[]`
- `Service` — один (`service`) или несколько (`services[]`)
- `Ingress`, `NetworkPolicy`
- `ConfigMap`, `Secret`
- `PersistentVolumeClaim` (с пропуском уже существующих)

Поддерживаются probes, resources, env/secrets, securityContext, nodeSelector/affinity/tolerations,
strategy, extraVolumes/extraVolumeMounts, а также аннотации-интеграции Prometheus / Istio / Fluentbit.

## Prerequisites

- Kubernetes `1.23+`
- Helm `3.8+`
- (опционально) Ingress-controller, если используется `ingress`
- (опционально) StorageClass, если используется `persistence`

## Установка

Из репозитория:

```bash
helm upgrade --install my-app ofa/ofa \
  -n my-namespace --create-namespace \
  -f values.yaml
```

Локально из исходников:

```bash
helm upgrade --install my-app . \
  -n my-namespace --create-namespace \
  -f values.yaml
```

Проверка перед установкой:

```bash
helm lint . -f values.yaml
helm template my-app . -f values.yaml
```

## Удаление

```bash
helm uninstall my-app -n my-namespace
```

> Примечание: PVC, созданные этим чартом, при удалении релиза **не удаляются**
> (поведение по умолчанию для PVC в Helm). Очисти их вручную, если нужно.

## Примеры

Готовые (живые) примеры values для каждого режима лежат в каталоге
[`ci/`](./ci). Каждый файл — это полностью рабочий values-файл, который
проходит `helm lint` и `helm template` в CI. Скачай нужный, поправь под себя
и передай через `-f`:

| Файл | Что покрывает |
|------|---------------|
| [`ci/deployment.yaml`](./ci/deployment.yaml) | Полный Deployment: strategy, probes, resources, env+secrets, configmap, PVC, extraVolumes, ingress, networkPolicy |
| [`ci/multi-service.yaml`](./ci/multi-service.yaml) | Single-app с несколькими Service (`services[]`: http + grpc + admin-NodePort) |
| [`ci/configmap.yaml`](./ci/configmap.yaml) | Несколько ConfigMap с `data` (конфиги) |
| [`ci/statefulset.yaml`](./ci/statefulset.yaml) | StatefulSet с persistence, configmap, extraVolumes |
| [`ci/job.yaml`](./ci/job.yaml) | Job с env, secrets, resources |
| [`ci/multi-app.yaml`](./ci/multi-app.yaml) | Несколько приложений одним релизом (`apps[]`) |

Установка с примером:

```bash
helm upgrade --install my-app . -n my-namespace --create-namespace -f ci/deployment.yaml
```

Примечания по режимам:
- `global.deploymentType` переключает `Deployment` ↔ `StatefulSet`.
- `service` и `services[]` взаимоисключающие (при наличии `services` одиночный `service` игнорируется). `containerPort` собирается из всех элементов `services`.
- В режиме `apps[]` каждое приложение поддерживает тот же набор полей, что и single-app.

## Параметры

### Глобальные

| Ключ | Тип | По умолчанию | Описание |
|------|-----|--------------|----------|
| `global.fullnameOverride` | string | `""` | Полная замена имени ресурсов |
| `global.nameOverride` | string | `""` | Частичная замена имени (дополняет release name) |
| `global.deploymentType` | string | `Deployment` | Тип workload: `Deployment` или `StatefulSet` |
| `global.image` | object | `{}` | Образ по умолчанию (repository/tag/pullPolicy) |
| `global.customLabels` | object | `{}` | Пользовательские labels для всех ресурсов |
| `global.customAnnotations` | object | `{}` | Пользовательские annotations |

### Образ и replicas

| Ключ | Тип | По умолчанию | Описание |
|------|-----|--------------|----------|
| `image.repository` | string | `""` | Docker-образ |
| `image.tag` | string | `latest` | Тег образа |
| `image.pullPolicy` | string | `IfNotPresent` | Kubernetes imagePullPolicy |
| `replicaCount` | int | `1` | Количество реплик (для Deployment) |
| `imagePullSecrets` | list | `[]` | Список существующих imagePullSecrets |
| `command` | list | `[]` | Переопределение entrypoint контейнера |
| `args` | list | `[]` | Аргументы entrypoint |

### Pod и контейнер

| Ключ | Тип | По умолчанию | Описание |
|------|-----|--------------|----------|
| `serviceAccount` | string | `""` | Имя ServiceAccount |
| `automountServiceAccountToken` | bool | `false` | Автомонтирование токена SA |
| `hostNetwork` | bool | `false` | Использовать hostNetwork |
| `nodeSelector` | object | `{}` | nodeSelector |
| `affinity` | object | `{}` | affinity-правила |
| `tolerations` | list | `[]` | tolerations |
| `securityContext.pod` | object | `{}` | pod-level securityContext |
| `securityContext.container` | object | `{}` | container-level securityContext |
| `env` | list | `[]` | Список `{name,value}` — переменные окружения |
| `secrets` | object | `{}` | Ключ/значение → Secret + `secretKeyRef` |
| `resources` | object | `{}` | `{cpu,memory}` — применяются к limits и requests |
| `livenessProbe` | object | `{}` | livenessProbe |
| `readinessProbe` | object | `{}` | readinessProbe |
| `strategy` | object | `{}` | Стратегия обновления (Deployment/StatefulSet) |

### Сеть

| Ключ | Тип | По умолчанию | Описание |
|------|-----|--------------|----------|
| `service` | object | `{}` | Одиночный Service |
| `services` | list | `[]` | Несколько Service (взаимоисключающе с `service`) |
| `ingress` | object | `{}` | Ingress |
| `networkPolicy` | object | `{}` | NetworkPolicy (ingress/egress) |

### Хранение и конфигурация

| Ключ | Тип | По умолчанию | Описание |
|------|-----|--------------|----------|
| `configmap` | list | `[]` | ConfigMap'ы с монтированием в pod (см. ниже) |
| `configmap[].name` | string | — | Имя ConfigMap (обязательно) |
| `configmap[].podMountPath` | string | — | Куда монтировать в контейнер |
| `configmap[].subPath` | string | `""` | Монтировать конкретный файл (subPath) |
| `configmap[].readOnly` | bool | `false` | Только чтение |
| `configmap[].data` | object | `{}` | Текстовые значения → `ConfigMap.data` |
| `persistence.claims` | list | `[]` | PVC (пропуск существующих через lookup) |
| `extraVolumes` | list | `[]` | Дополнительные тома (emptyDir/secret/configMap/...) |
| `extraVolumeMounts` | list | `[]` | Монтирования для extraVolumes |

### Job

| Ключ | Тип | По умолчанию | Описание |
|------|-----|--------------|----------|
| `job.image` | object | `{}` | Образ Job |
| `job.command` | list | `[]` | Команда Job |
| `job.backoffLimit` | int | — | Лимит перезапусков |
| `job.activeDeadlineSeconds` | int | — | Дедлайн выполнения |
| `job.restartPolicy` | string | — | `Never` или `OnFailure` |
| `job.env` | list | `[]` | Переменные окружения Job |
| `job.resources` | object | `{}` | Ресурсы Job (limits/requests) |

### Интеграции (annotations)

Эти поля попадают в `annotations` ресурсов и подхватываются соответствующей
интеграцией, если она установлена в кластере:

| Ключ | Описание |
|------|----------|
| `monitoring.scrape` / `.port` / `.path` | Prometheus auto-discovery |
| `istio.inject` | sidecar injection (Istio) |
| `logging.parser` | Fluentbit / Loki / Vector |

### Multi-app

`apps[]` — список приложений. Каждый элемент поддерживает тот же набор полей,
что и single-app режим (`image`, `service`/`services`, `env`, `resources`, …),
плюс обязательное `name`.

## Рекомендации

- Stateless-приложения → режим `Deployment` (по умолчанию).
- БД и приложения с постоянным диском → `global.deploymentType: StatefulSet`.
- Миграции и разовые задачи → секция `job`.
- Если PVC уже существует в namespace, чарт пропустит его повторное создание.
  Это помогает при повторных установках, но Helm не начнёт управлять уже
  существующим PVC как своим ресурсом.
- Для production храни чувствительные значения в отдельном values-файле или
  передавай через `--set` / внешний secret-менеджер, а не коммить в репозиторий.

## License

MIT © Armen Akopyan
