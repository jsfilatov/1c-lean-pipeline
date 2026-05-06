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
| фаза_следующей_работы | 0–11 (см. SKILL.md); при ожидании решения о документации часто `9` при `ожидается_gate: g_doc`, при финальных delta specs — `10`, при архиве — `11` |
| ожидается_gate | — \| g0_understanding \| g1_prd \| g2_architecture \| g3_tasks \| g_doc \| g_delta_specs \| g_archive |
| phase_status | not_started \| in_progress \| waiting_gate \| done \| blocked |
| current_call_id | — |
| current_handoff | — |
| current_artifact | — |
| current_task_id | — |
| gate_revisions | proposal=0; design=0; tasks=0; specs=0; archive=0 |
| last_completed_checkpoint | — |
| примечание | одна строка для человека |

`openspec_change` обязателен. Если change уже перемещён в `openspec/changes/archive/**`, активное возобновление по этому состоянию не выполняется; исключение — восстановление фазы 11 после закрытого `g_archive`, когда нужно только отметить архив завершённым и не повторять перенос.

После успешного ревью кода см. в `SKILL.md` § «Фазы 9–11 и gate `g_doc`, `g_delta_specs`, `g_archive`»: отдельный вопрос пользователю перед фазой 9, финальное утверждение delta specs и отдельный вопрос перед архивированием.

## Краткая хронология (опционально)

- YYYY-MM-DD — …
