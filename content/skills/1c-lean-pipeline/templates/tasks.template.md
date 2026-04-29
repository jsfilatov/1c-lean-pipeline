# Deprecated: tasks template

Новые задачи `1c-lean-pipeline` не создают `.tasks/task-*/tasks.md`.

Используйте OpenSpec:

- `openspec/changes/<change-id>/tasks.md`

Задачи должны оставаться совместимыми с OpenSpec apply/archive: стандартные чекбоксы `- [ ]` / `- [x]`, один атомарный пункт на единицу работы. Служебный индекс контекста для разработки хранится отдельно: `.tasks/task-*/phase9-context-index.md`.
