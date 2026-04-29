## OpenSpec design доработки 1С

## Машинный handoff (JSON)

- **Запрос:** `{{HANDOFF_JSON}}` — JSON, соответствующий схеме `schemas/handoff-request.schema.json`. Сначала используй `slices`, `anchors`, `read_paths`; полные gate-файлы читай по `gate_documents.*.path`, если среза недостаточно или есть риск устаревания после правок пользователя на gate (ориентир — `source_revision` в JSON и фактическое содержимое файла).
- **Ответ (опционально):** если оркестратор подставил непустой путь `{{HANDOFF_RESPONSE_JSON}}`, запиши туда JSON по схеме `schemas/handoff-response.schema.json`; иначе достаточно раздела «Ответ в чат» ниже.

- **Каталог задачи:** {{TASK_DIR}}
- **Сложность:** {{COMPLEXITY}}

## Обязательно прочитай

1. Срезы из `{{HANDOFF_JSON}}` (`slices.req_items`, `slices.discovery_summary`, `read_paths`, `anchors`).
2. Утверждённый proposal: `gate_documents.proposal.path` — при необходимости целиком в рабочей копии, в чат не копируй.
3. При отсутствии среза — `{{TASK_DIR}}/discovery.md` (если есть), `{{TASK_DIR}}/phase1-requirements.md`

## Результат

Файл **`gate_documents.design.path`** (`openspec/changes/<change-id>/design.md`):

- Решения: какие объекты метаданных / модули / регистры затронуты
- Потоки данных и границы транзакций (если применимо)
- Порядок внедрения и зависимости
- Риски и альтернативы (кратко)

Следуй формату OpenSpec и, если оркестратор передал инструкции CLI, шаблону `openspec instructions design --change "<change-id>" --json`. Не создавай `.tasks/task-*/architecture.md`.

Для **простая** — укороченный `design.md` по соглашению в `SKILL.md`.

## Ответ в чат

3–7 строк + путь к `design.md`.

