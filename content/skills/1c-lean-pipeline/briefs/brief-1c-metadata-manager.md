## Метаданные / формы / CFE по таску

## Машинный handoff (JSON)

- **Запрос:** `{{HANDOFF_JSON}}` — JSON, соответствующий схеме `schemas/handoff-request.schema.json`. Сначала используй `slices`, `anchors`, `read_paths`; полные gate-файлы читай по `gate_documents.*.path`, если среза недостаточно или есть риск устаревания после правок пользователя на gate (ориентир — `source_revision` в JSON и фактическое содержимое файла).
- **Ответ (опционально):** если оркестратор подставил непустой путь `{{HANDOFF_RESPONSE_JSON}}`, запиши туда JSON по схеме `schemas/handoff-response.schema.json`; иначе достаточно раздела «Ответ в чат» ниже.

- **Каталог задачи:** {{TASK_DIR}}
- **Таск:** {{TASK_ID}}
- **Фокус:** {{FOCUS}}

## Обязательно прочитай

1. `{{HANDOFF_JSON}}` — `slices.task_slice`, `slices.context_index_for_task`, `slices.req_items` (для {{REQ_IDS}}), `anchors`, `read_paths`.
2. При необходимости полного текста — `gate_documents.tasks.path`, `gate_documents.design.path`, `gate_documents.proposal.path`, `spec_deltas[]`

## Действия

- Создай/измени объекты метаданных, формы, расширение — строго в рамках таска.
- Следуй skill `1c-metadata-manage` из базового набора `ai_rules_1c` и валидации после шагов.
- Обнови OpenSpec `gate_documents.tasks.path` для {{TASK_ID}} стандартным чекбоксом `- [x]` только после завершения.
- Delta specs обновляй только если меняется контракт/поведение метаданных, а не при чисто технической правке.

## Ответ в чат

Список созданных/изменённых файлов + результаты валидации (кратко).

