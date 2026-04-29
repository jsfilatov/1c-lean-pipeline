## Реализация по таску (BSL / логика)

## Машинный handoff (JSON)

- **Запрос:** `{{HANDOFF_JSON}}` — JSON, соответствующий схеме `schemas/handoff-request.schema.json`. Сначала используй `slices`, `anchors`, `read_paths`; полные gate-файлы читай по `gate_documents.*.path`, если среза недостаточно или есть риск устаревания после правок пользователя на gate (ориентир — `source_revision` в JSON и фактическое содержимое файла).
- **Ответ (опционально):** если оркестратор подставил непустой путь `{{HANDOFF_RESPONSE_JSON}}`, запиши туда JSON по схеме `schemas/handoff-response.schema.json`; иначе достаточно раздела «Ответ в чат» ниже.

- **Каталог задачи:** {{TASK_DIR}}
- **Таск:** {{TASK_ID}}
- **Фокус:** {{FOCUS}}

## Обязательно прочитай

1. `{{HANDOFF_JSON}}` — `slices.task_slice`, `slices.context_index_for_task`, `slices.req_items` (для {{REQ_IDS}}), `slices.architecture_section_ids`, `anchors`, `read_paths`.
2. При необходимости полного текста — `gate_documents.tasks.path` (строка {{TASK_ID}}), `gate_documents.proposal.path`, `gate_documents.design.path`, `spec_deltas[]`

## Действия

- Внеси изменения в код согласно критерию готовности таска.
- Обнови OpenSpec `gate_documents.tasks.path`: отметь {{TASK_ID}} стандартным чекбоксом `- [x]` только после завершения.
- Delta specs изменяй только если реализация меняет согласованное наблюдаемое поведение; не трогай их при чисто технической правке.
- Соблюдай стиль BSL: правило `dev-standards-core` из базового набора `ai_rules_1c`, корневой `AGENTS.md` (процедура разработки и инструменты).

## Ответ в чат

Список изменённых файлов (полные пути) + 3–7 строк итога. Без листинга всего кода.

