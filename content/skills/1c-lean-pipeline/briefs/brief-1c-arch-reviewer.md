## Ревью архитектуры 1С

## Машинный handoff (JSON)

- **Запрос:** `{{HANDOFF_JSON}}` — JSON, соответствующий схеме `schemas/handoff-request.schema.json`. Сначала используй `slices`, `anchors`, `read_paths`; полные gate-файлы читай по `gate_documents.*.path`, если среза недостаточно или есть риск устаревания после правок пользователя на gate (ориентир — `source_revision` в JSON и фактическое содержимое файла).
- **Ответ (опционально):** если оркестратор подставил непустой путь `{{HANDOFF_RESPONSE_JSON}}`, запиши туда JSON по схеме `schemas/handoff-response.schema.json`; иначе достаточно раздела «Ответ в чат» ниже.

- **Каталог задачи:** {{TASK_DIR}}
- **Фокус:** {{FOCUS}}

## Обязательно прочитай

1. Срезы из `{{HANDOFF_JSON}}` (в т.ч. `slices.req_items`, `read_paths`).
2. `gate_documents.design.path`, `gate_documents.proposal.path` и `spec_deltas[]` — для полной сверки требований и решений.

## Результат

Файл **`{{TASK_DIR}}/architecture-review.md`**:

- Вердикт (ок / доработать) с обоснованием
- Замечания с приоритетом (блокер / важно / желательно)
- Явные ссылки на requirement / scenario, если есть несоответствие

## Ответ в чат

3–7 строк + путь к `architecture-review.md`.

