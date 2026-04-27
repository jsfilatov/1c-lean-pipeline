# Deprecated: PRD template

Новые задачи `1c-lean-pipeline` не создают `.tasks/task-*/prd.md`.

Используйте OpenSpec:

- `openspec/changes/<change-id>/proposal.md`
- `openspec/changes/<change-id>/specs/<domain>/spec.md`

Формат change и delta specs описан в `openspec/changes/README.md`. При доступном OpenSpec CLI получайте актуальный шаблон через `openspec instructions proposal --change "<change-id>" --json`.
