# Состояние конвейера (1c-lean-pipeline)

| Поле | Значение |
|------|----------|
| skill | 1c-lean-pipeline |
| feature_slug | [feature-slug] |
| openspec_change | openspec/changes/[change-id] |
| режим | strict \| fast_track |
| fast_track_основание | — (краткая цитата из чата при `fast_track`) |
| fast_track_дата | — |
| сложность | простая \| средняя \| сложная \| критичная |
| фаза_следующей_работы | 0–9 (см. SKILL.md); при ожидании решения о документации часто `9` при `ожидается_gate: g_doc` |
| ожидается_gate | — \| g0_understanding \| g1_prd \| g2_architecture \| g3_tasks \| g_doc |
| phase_status | not_started \| in_progress \| waiting_gate \| done \| blocked |
| current_call_id | — |
| current_handoff | — |
| current_artifact | — |
| current_task_id | — |
| gate_revisions | proposal=0; design=0; tasks=0; specs=0 |
| last_completed_checkpoint | — |
| примечание | одна строка для человека |

`openspec_change` обязателен. Если change уже перемещён в `openspec/changes/archive/**`, активное возобновление по этому состоянию не выполняется.

После успешного ревью кода см. в `SKILL.md` § «Фаза 9 и gate `g_doc`»: отдельный вопрос пользователю перед фазой 9.

## Краткая хронология (опционально)

- YYYY-MM-DD — …
