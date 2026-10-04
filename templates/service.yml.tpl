# Application сервиса __NAME__ в dev. Создан автоматически (scripts/new-service.sh); строки с "bot:" обновляет CI.
# Настройки сервиса под окружение dev лежат В РЕПОЗИТОРИИ СЕРВИСА: .helm/values-dev.yaml (необязательный файл).
# Общие значения окружения (NATS, JWT, ...): values/dev-common.yaml в этом репозитории.
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: dev-__NAME__
  namespace: argocd
  annotations: { argocd.argoproj.io/sync-wave: "5" }
  finalizers:
    - resources-finalizer.argocd.argoproj.io
spec:
  project: arba
  sources:
    - repoURL: __REPO_URL__
      targetRevision: main # bot:revision
      path: .helm
      helm:
        releaseName: __NAME__
        ignoreMissingValueFiles: true
        valueFiles:
          - $platform/values/dev-common.yaml
          - values-dev.yaml
        valuesObject:
          global:
            env: dev
            tier: __TIER__
          image:
            repository: __IMAGE_REPO__
            tag: "0.0.0" # bot:tag
            digest: "" # bot:digest
    - repoURL: http://gitlab.arba.kz/argocd/argocd-dev.git
      targetRevision: main
      ref: platform
  destination:
    server: https://kubernetes.default.svc
    namespace: dev
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    retry:
      limit: 5
      backoff: { duration: 10s, factor: 2, maxDuration: 3m }
