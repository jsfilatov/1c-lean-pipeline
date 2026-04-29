## Ревью кода 1С

## Машинный handoff (JSON)

- **Запрос:** `{{HANDOFF_JSON}}` — JSON, соответствующий схеме `schemas/handoff-request.schema.json`. Сначала используй `slices`, `anchors`, `read_paths`; полные gate-файлы читай по `gate_documents.*.path`, если среза недостаточно или есть риск устаревания после правок пользователя на gate (ориентир — `source_revision` в JSON и фактическое содержимое файла).
- **Ответ (опционально):** если оркестратор подставил непустой путь `{{HANDOFF_RESPONSE_JSON}}`, запиши туда JSON по схеме `schemas/handoff-response.schema.json`; иначе достаточно раздела «Ответ в чат» ниже.

- **Каталог задачи:** {{TASK_DIR}}
- **Область:** {{FILES_SCOPE}}

## Контекст (прочитай файлы в рабочей копии, в чат не вставляй целиком)

1. `{{HANDOFF_JSON}}` — `slices.req_items` / `req_ids`, `files_scope`, при наличии `slices.code_review_summary`.
2. `gate_documents.proposal.path`, `gate_documents.design.path`, `gate_documents.tasks.path`, `spec_deltas[]` — если нужна полная сверка требований, решений и истории тасков.

## Результат

Файл **`{{TASK_DIR}}/code-review.md`** или явный список замечаний с указанием файла и серьёзности (блокер / важно / замечание).

Фокус: только существенные проблемы (без шума).

## Ответ в чат

3–7 строк: итог ревью + путь к артефакту ревью.

