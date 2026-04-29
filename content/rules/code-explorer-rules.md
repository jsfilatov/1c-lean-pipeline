---

description: Правила исследования кодовой базы 1C

alwaysApply: true

---

### Шаблоны путей

- Список объектов конфигурации: `Configuration.xml`.
- Метаданные объекта: `[Type]/[Name].xml`.

| Назначение | Шаблон |
|------------|--------|
| Модуль объекта | `[Type]/[Name]/Ext/ObjectModule.bsl` |
| Модуль менеджера | `[Type]/[Name]/Ext/ManagerModule.bsl` |
| Команда | `[Type]/[Name]/Commands/[CommandName]/Ext/CommandModule.bsl` |
| Форма (структура) | `[Type]/[Name]/Forms/[FormName]/Ext/Form.xml` |
| Модуль формы | `[Type]/[Name]/Forms/[FormName]/Ext/Form/Module.bsl` |
| Общая форма (структура) | `CommonForms/[Name]/Ext/Form.xml` |
| Общая форма (модуль) | `CommonForms/[Name]/Ext/Form/Module.bsl` |
| Константа (модуль) | `Constants/[Name]/Ext/ValueManagerModule.bsl` |
| Определяемый тип | `DefinedTypes/[Name].xml` |
| Перечисление (модуль) | `Enums/[Name]/Ext/ManagerModule.bsl` |
| Роль | `Roles/[Name]/Ext/Rights.xml` |
| План счетов (предопределённые) | `ChartsOfAccounts/[Name]/Ext/Predefined.xml` |
| ПВХ (предопределённые) | `ChartsOfCharacteristicTypes/[Name]/Ext/Predefined.xml` |

**Общие модули:** `CommonModules/[Имя]/Ext/Module.bsl` (в таблице `[Type]` не задаётся).

**Пример подстановки** `Catalogs` / `Номенклатура`: `Catalogs/Номенклатура.xml`, `Catalogs/Номенклатура/Ext/ManagerModule.bsl`, `Catalogs/Номенклатура/Forms/ФормаВыбора/Ext/Form.xml`, `Catalogs/Номенклатура/Forms/ФормаВыбора/Ext/Form/Module.bsl`.

### `Type` в путях (регистр и написание — строго)

Только: Catalogs, Documents, InformationRegisters, AccumulationRegisters, AccountingRegisters, DataProcessors, Constants, CommonForms, CommonCommands, DocumentJournals, BusinessProcesses, DefinedTypes, Enums, Reports, Roles, ChartsOfCharacteristicTypes, ChartsOfAccounts.

### Алиасы (только распознавание; пути — только английские `Type`)

| RU / EN (фрагмент) | Путь `Type` |
|--------------------|-------------|
| Справочник, Справочники, Catalog | Catalogs |
| Документ, Документы, Document | Documents |
| РегистрСведений, …, InformationRegister | InformationRegisters |
| РегистрНакопления, …, AccumulationRegister | AccumulationRegisters |
| РегистрБухгалтерии, …, AccountingRegister | AccountingRegisters |
| Обработка, …, DataProcessor | DataProcessors |
| Константа, …, Constant | Constants |
| ОбщаяФорма, …, CommonForm | CommonForms |
| ЖурналДокументов, …, DocumentJournal | DocumentJournals |
| БизнесПроцесс, …, BusinessProcess | BusinessProcesses |
| ОбщаяКоманда, …, CommonCommand | CommonCommands |
| ОпределяемыйТип, …, DefinedType | DefinedTypes |
| Перечисление, …, Enum | Enums |
| Отчет, …, Report | Reports |
| Роль, …, Role | Roles |
| ПланВидовХарактеристик, …, ChartsOfCharacteristicType | ChartsOfCharacteristicTypes |
| ПланСчетов, …, ChartsOfAccount | ChartsOfAccounts |

### Lean pipeline: якоря HandoffRequest (`1c-lean-pipeline`)

- JSON по схеме `1c-lean-pipeline/schemas/handoff-request.schema.json`, поле `anchors[]`: после MCP-first — **подсказки стартовых точек**; не подменяй ими вывод, если код или MCP иначе.
- Расхождение якоря с файлом → приоритет у **факта** в файле и у MCP.

### RULE: MCP-FIRST

- Имена инструментов, серверы MCP и цепочка до Grep — корневой **`AGENTS.md`** (разделы **# Tooling**, **Graph / Code-Metadata Task Map**, **Important Rules** п.7); при изменении набора инструментов ориентир — он.
- Пока в сессии есть подходящий MCP — **сначала** MCP; grep и «полный Read неизвестного» — после MCP или после разрешения пути шаблоном.
- Поиск кода: при доступном **`1c-graph-metadata-mcp`** — сначала **`search_code`**, иначе **`codesearch`** (`1c-code-metadata-mcp`) — как в *Graph / Code-Metadata Task Map* и п.7 `AGENTS.md`.
- grep / Read (`offset`/`limit`) / sed — вторичны: после файла и якоря (MCP или шаблон). Если MCP вернул диапазон строк — Read с `offset`/`limit` без предварительного grep.
- **Запрет:** grep как основной способ найти неизвестное, если в `AGENTS.md` для задачи предусмотрен MCP-эквивалент.

### RULE: NO DUPLICATE MCP SEARCHES

- MCP — discovery; после нахождения — шаблоны путей и прямое чтение.
- `ОбщийМодуль.Метод()` → `CommonModules/ОбщийМодуль/Ext/Module.bsl` → читать файл напрямую, **без** повторного codesearch по имени метода.
- Повторный MCP только если: объект неизвестен; нужны все вхождения шаблона по конфигурации; путь по шаблону отсутствует (fallback).
- Один MCP-запрос на одну новую задачу discovery; тот же запрос не повторять.

### RULE: STRICT 1C FILE RESOLUTION

- Ссылка на объект метаданных → **без** глобального обхода репозитория; путь **только** по шаблонам выше и только перечисленные `Type`.
- Файла нет по ожидаемому пути — сообщи явно, **не** ищи «где угодно ещё».
- Логика → сначала `*.bsl`; структура / UI → `*.xml`.

### TOKEN ECONOMY и вывод ответа

1. Не читать файлы целиком (включая полный просмотр файла).
2. Чтение только **фрагментарно** после grep-hit, якоря MCP или шаблона (цель: процедура/строка). Один файл — одно чтение контекста; снова — только при **новом** grep-hit/якоре и непокрытом блоке. Не открывать «для ознакомления»: сначала цель (**search_code** / **codesearch**, **search_function**, **get_module_structure**, grep), затем одно извлечение. Сначала сузь область (объект, `CommonModules`, …), потом поиск — не вся конфигурация сразу. Без подтверждённого вхождения файл не открывать.
3. После якоря: базовое окно **±100** строк. В `.bsl` — вся процедура/функция с директивами; длина ≤200 строк — целиком; >200 — ±100 вокруг совпадения. XML >200 строк — сначала **первые 150** строк (тип объекта и база после xmlns); grep по XML — **±50**; шапка vs ТЧ — по родителю (`<TabularSection>`, `<Attributes>`, `<Commands>`); пользовательские названия — через `<Synonym>` к техническому имени реквизита.
4. Цитаты логики из `*.bsl`; реквизиты/метаданные формы из `*.xml`.
5. **Подробный ответ не отменяет экономию чтения:** в ответе — трассировка, выводы, нюансы; ключевые фрагменты кода с `// ... код пропущен ...` для остального; обязательны **ссылки на файлы со строками** и явные имена реквизитов объектов/форм. Раздувать ответ полным перечитыванием больших файлов — запрещено.

### TRACE (call stack)

0. До поиска — 3–5 гипотез мест (форма, менеджер, общий модуль, подписка, регистр).
1. Распутывать цепочки вызовов, не один файл изолированно.
2. Искать место решения задачи с переходами по объектам; «пусто в этом модуле» → логика может быть в связанном объекте.
3. Поток: откуда данные → куда передаются → где логика; модель — **граф**.

### Strict mode

Детерминизм важнее догадок; невидимый код не выдумывать — находить инструментами. Финальный вывод — после проверки цепочки по нескольким файлам. Только факты из файлов и MCP; гипотезы без опоры — нет. Упоминание другого объекта — проследить до вывода.
