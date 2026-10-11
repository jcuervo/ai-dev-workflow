# {{repo name}}

{{One or two sentences: what this service owns (domain, main APIs/events) and who calls it. Same wording as its description in the repo registry.}}

## Stack
- {{Rails x.y, Ruby x.y, PostgreSQL / MySQL / SQLite, Sidekiq / Solid Queue, …}}
- Runs in: {{Docker Compose service `web` (compose file: `docker-compose.yml`) | locally}}
- Tests: {{RSpec (`spec/`) with FactoryBot | Minitest}}

## Commands
Run from the repo root. {{If Docker: the stack must be up (`docker compose up -d`).}}

| Purpose | Command |
|---|---|
| Start | {{`docker compose up -d` / `bin/dev`}} |
| All specs | {{`docker compose exec -T web bundle exec rspec`}} |
| One spec | {{`docker compose exec -T web bundle exec rspec spec/path_spec.rb`}} |
| Lint | {{`bundle exec rubocop`}} |
| Security | {{`bundle exec brakeman -q --no-pager` · `bundle exec bundle-audit check`}} |
| Migrate | {{`docker compose exec -T web bin/rails db:migrate`}} (updates `db/schema.rb`; never edit it by hand) |
| Console | {{`docker compose exec web bin/rails console`}} |

## Conventions
- {{Spec types used and where: request specs for endpoints, no controller specs, …}}
- {{Where business logic lives: models, service objects (`app/services`), interactors, …}}
- {{API style: serializers, versioning, error format}}
- {{Background jobs, events: how they're named and tested}}

## Integrations
- {{Calls: other services/APIs this repo calls, and how it's configured locally}}
- {{Called by / consumes: who depends on this service's APIs or events}}

## Gotchas
- {{Things that waste time: seeds needed, env vars, flaky areas, slow suites, local-only quirks}}

<!-- Keep this file short (under ~80 lines) and current. Commands must be copy-paste correct.
     Generated with /repo-setup; edit freely. -->
