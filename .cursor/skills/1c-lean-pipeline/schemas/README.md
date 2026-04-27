# JSON Schema handoff (`1c-lean-pipeline`)

Используется **вариант 1** из плана: перед вызовом `Task` оркестратор материализует файл запроса в каталоге задачи (см. `SKILL.md`, раздел «JSON handoff»).

| Файл | Назначение |
|------|------------|
| [handoff-request.schema.json](handoff-request.schema.json) | Структура `HandoffRequest`: фаза, субагент, обязательный `openspec_change`, фазозависимые OpenSpec `gate_documents` + `source_revision`, `spec_deltas`, срезы `slices`, `anchors` |
| [handoff-response.schema.json](handoff-response.schema.json) | Структура `HandoffResponse`: ссылка на `call_id`, краткое резюме, пути артефактов |

Примеры экземпляров: [`templates/handoff-request.example.json`](../templates/handoff-request.example.json), [`templates/handoff-response.example.json`](../templates/handoff-response.example.json).
