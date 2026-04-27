# Шаблоны служебных артефактов задачи

Каталог задачи: **`.tasks/task-[feature-slug]/`** (создаёт оркестратор в фазе 0). SDD-артефакты живут не здесь, а в активном **`openspec/changes/<change-id>/`**.

| Файл | Назначение |
|------|------------|
| `workflow-state.md` | Режим, фаза, висящий gate, `openspec_change`, checkpoint/resume — см. `workflow-state.template.md` |
| `phase0-complexity.md` | Уровень сложности + обоснование |
| `phase1-requirements.md` | Запрос, Q&A, резюме, подтверждение пользователя |
| `discovery.md` | Вывод `1c-code-explorer` |
| `architecture-review.md` | Опционально, после `1c-arch-reviewer` |
| `phase9-context-index.md` | Индекс контекста по таскам для разработки |
| `code-review.md` | Результат ревью |
| `handoff/request-*.json` | **HandoffRequest** перед вызовом субагента (см. `schemas/handoff-request.schema.json`, пример `handoff-request.example.json`) |
| `handoff/response-*.json` | Опционально **HandoffResponse** после фазы (см. `schemas/handoff-response.schema.json`) |
| `handoff.example.json` | Устаревший плоский пример; для новых задач ориентируйтесь на `handoff-request.example.json` |

OpenSpec-артефакты:

| Файл | Назначение |
|------|------------|
| `openspec/changes/<change-id>/proposal.md` | Что и зачем меняется |
| `openspec/changes/<change-id>/design.md` | Как реализуется изменение |
| `openspec/changes/<change-id>/tasks.md` | Implementation checklist с `- [ ]` / `- [x]` |
| `openspec/changes/<change-id>/specs/**/spec.md` | Delta specs: ADDED / MODIFIED / REMOVED |

Формат OpenSpec см. в `openspec/changes/README.md`; при доступном CLI используйте `openspec instructions <artifact-id> --change "<change-id>" --json`.

Готовые заготовки в этом каталоге:

- `workflow-state.template.md`
- `phase0-complexity.template.md`
- `phase1-requirements.template.md`
- `discovery.template.md`
- `prd.template.md` (deprecated, только указатель на OpenSpec)
- `architecture.template.md` (deprecated, только указатель на OpenSpec)
- `tasks.template.md` (deprecated, только указатель на OpenSpec)
- `phase9-context-index.template.md`
- `handoff.example.json` (наследие)
- `handoff-request.example.json`, `handoff-response.example.json`
- `../schemas/handoff-request.schema.json`, `../schemas/handoff-response.schema.json`

Копирование: дублируйте `*.template.md` в каталог задачи и уберите суффикс `.template` или создайте файлы по структуре вручную.
