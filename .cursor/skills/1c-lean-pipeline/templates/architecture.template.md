# Deprecated: architecture template

Новые задачи `1c-lean-pipeline` не создают `.tasks/task-*/architecture.md`.

Используйте OpenSpec:

- `openspec/changes/<change-id>/design.md`

`design.md` для этого конвейера обязателен, даже если схема OpenSpec допускает его как опциональный артефакт. При доступном OpenSpec CLI получайте актуальный шаблон через `openspec instructions design --change "<change-id>" --json`.
