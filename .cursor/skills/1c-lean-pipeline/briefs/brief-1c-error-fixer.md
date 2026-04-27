## Точечное исправление ошибок 1С

## Машинный handoff (JSON)

- **Запрос:** `{{HANDOFF_JSON}}` — JSON, соответствующий схеме `.cursor/skills/1c-lean-pipeline/schemas/handoff-request.schema.json`. Сначала используй `slices`, `anchors`, `read_paths`; полные gate-файлы читай по `gate_documents.*.path`, если среза недостаточно или есть риск устаревания после правок пользователя на gate (ориентир — `source_revision` в JSON и фактическое содержимое файла).
- **Ответ (опционально):** если оркестратор подставил непустой путь `{{HANDOFF_RESPONSE_JSON}}`, запиши туда JSON по схеме `.cursor/skills/1c-lean-pipeline/schemas/handoff-response.schema.json`; иначе достаточно раздела «Ответ в чат» ниже.

- **Каталог задачи:** {{TASK_DIR}}
- **Фокус:** {{FOCUS}}

## Обязательно прочитай

1. `{{HANDOFF_JSON}}` — `slices.code_review_summary`, `files_scope`, `read_paths`.
2. `{{TASK_DIR}}/code-review.md` — если в handoff нет среза по ревью.
3. Указанные файлы: {{FILES_SCOPE}}

## Действия

Минимальные правки для устранения ошибки; без рефакторинга «заодно». После правок — при необходимости отметка в OpenSpec `gate_documents.tasks.path`.

## Ответ в чат

Список исправленных файлов + кратко, что сделано.
