## OpenSpec tasks и индекс контекста 1С

## Машинный handoff (JSON)

- **Запрос:** `{{HANDOFF_JSON}}` — JSON, соответствующий схеме `.cursor/skills/1c-lean-pipeline/schemas/handoff-request.schema.json`. Сначала используй `slices`, `anchors`, `read_paths`; полные gate-файлы читай по `gate_documents.*.path`, если среза недостаточно или есть риск устаревания после правок пользователя на gate (ориентир — `source_revision` в JSON и фактическое содержимое файла).
- **Ответ (опционально):** если оркестратор подставил непустой путь `{{HANDOFF_RESPONSE_JSON}}`, запиши туда JSON по схеме `.cursor/skills/1c-lean-pipeline/schemas/handoff-response.schema.json`; иначе достаточно раздела «Ответ в чат» ниже.

- **Каталог задачи:** {{TASK_DIR}}

## Обязательно прочитай

1. `{{HANDOFF_JSON}}` — `slices.req_items`, `slices.discovery_summary`, `read_paths`, `anchors`.
2. Полные gate-документы при необходимости: `gate_documents.proposal.path`, `gate_documents.design.path`
3. Если есть ревью архитектуры и нет среза — `{{TASK_DIR}}/architecture-review.md`
4. Если discovery нужен целиком — `{{TASK_DIR}}/discovery.md` (если есть)

## Результат

1. **`gate_documents.tasks.path`** (`openspec/changes/<change-id>/tasks.md`) — подзадачи со стандартными OpenSpec чекбоксами:
   - описание, зависимости, критерий готовности, предполагаемый исполнитель (`1c-developer` | `1c-metadata-manager` | смешанный)
   - ссылки на requirements / scenarios из `proposal.md` и delta specs
2. **`{{TASK_DIR}}/phase9-context-index.md`** — для каждого `T-xx`: какие пути/объекты трогать (кратко), чтобы разработчик не искал контекст по всему репо

Порядок тасков должен быть выполнимым с учётом зависимостей. Не создавай `.tasks/task-*/tasks.md`.

## Ответ в чат

3–7 строк + пути к OpenSpec `tasks.md` и `phase9-context-index.md`.
