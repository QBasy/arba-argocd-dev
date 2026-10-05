          replicaCount: 1
          migrate:
            enabled: true                       # PreSync Job: cmd/migrate up
          env:
            __UP___LOG_LEVEL: debug
            __UP___NATS_URL: nats://nats.broker.svc.cluster.local:4222
            __UP___JWT_JWKS_URL: http://identity.dev.svc.cluster.local/.well-known/jwks.json
            __UP___JWT_ISSUER: http://identity.dev.arba.kz
            __UP___JWT_AUDIENCE: arba
          secretEnv:
            - { name: __UP___DATABASE_DSN, secret: __NAME__-db, key: dsn }
