# argocd-dev

GitOps-репозиторий окружения dev: здесь лежат манифесты Argo CD Application.

- `bootstrap/` — AppProject `arba` и корневое приложение `root-dev` (применяется один раз).
- `dev/*.yml` — по файлу на сервис; root-dev создаёт из них приложения автоматически.
- `scripts/bump.sh` — CI сервиса обновляет ревизию, тег и digest образа (строки с `# bot:`).

Новый сервис: скопировать `dev/arba-docs.yml`, поправить имя, репо, образ, host. Закоммитить в main.
