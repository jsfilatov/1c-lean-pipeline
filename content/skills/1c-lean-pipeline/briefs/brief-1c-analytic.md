## OpenSpec proposal и delta specs для доработки 1С

Этот бриф используется в двух режимах:

- **Фаза 3:** создать `proposal.md` и initial delta specs.
- **Фаза 10:** только если нужна корректировка требований без правок кода/метаданных; расхождения, вызванные реализацией, эскалируй владельцу изменения (`1c-developer` / `1c-metadata-manager`) и не правь delta specs сам. `1c-error-fixer` не является владельцем delta specs.

## Машинный handoff (JSON)

- **Запрос:** `{{HANDOFF_JSON}}` — JSON, соответствующий схеме `.cursor/skills/1c-lean-pipeline/schemas/handoff-request.schema.json`. Сначала используй `slices`, `anchors`, `read_paths`; полные gate-файлы читай по `gate_documents.*.path`, если среза недостаточно или есть риск устаревания после правок пользователя на gate (ориентир — `source_revision` в JSON и фактическое содержимое файла).
- **Ответ (опционально):** если оркестратор подставил непустой путь `{{HANDOFF_RESPONSE_JSON}}`, запиши туда JSON по схеме `.cursor/skills/1c-lean-pipeline/schemas/handoff-response.schema.json`; иначе достаточно раздела «Ответ в чат» ниже.

- **Каталог задачи:** {{TASK_DIR}}
- **Сложность:** {{COMPLEXITY}}

## Обязательно прочитай

1. Срезы и пути из `{{HANDOFF_JSON}}` (в т.ч. `slices.phase1_summary`, `slices.discovery_summary`, `read_paths`).
2. Если в handoff нет нужного среза — `{{TASK_DIR}}/phase1-requirements.md`
3. Если discovery нужен полностью — `{{TASK_DIR}}/discovery.md` (если есть)
4. Если нужен полный контекст сложности — `{{TASK_DIR}}/phase0-complexity.md`

## Результат

Файлы OpenSpec:

1. **`gate_documents.proposal.path`** (`openspec/changes/<change-id>/proposal.md`)
2. **`spec_deltas[]`** (`openspec/changes/<change-id>/specs/<domain>/spec.md`)

- Следуй формату OpenSpec из `openspec/changes/README.md` и, если оркестратор передал инструкции CLI, шаблону `openspec instructions proposal --change "<change-id>" --json`.
- Требования в delta specs оформляй как `### Requirement:` и сценарии как `#### Scenario:`.
- Фаза 3 не считается завершённой без минимум одного реального delta-файла с содержательной секцией `## ADDED Requirements`, `## MODIFIED Requirements` или `## REMOVED Requirements` и хотя бы одним `### Requirement:`.
- В фазе 10 не трогай `openspec/specs/**` и не меняй код/метаданные. Если delta specs расходятся с фактической реализацией, верни краткую эскалацию: какие файлы delta затронуты, какой владелец должен исправить, какие `REQ-*` / секции требуют внимания.
- Не создавай `.tasks/task-*/prd.md`.
- Для **простая** — допускается компактный proposal; явно пометь неясности вопросами к пользователю в конце документа.

## Ответ в чат

3–7 строк + пути к `proposal.md` и delta specs. Не дублируй полный текст в ответ.
