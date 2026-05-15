# Dashboard — CLAUDE.md

## Project Overview

**App name:** Dashboard (internal name: GoalDigger)
**Platform:** iOS (SwiftUI, light mode only)
**Entry point:** `goalDiggerApp.swift` — `GoalDiggerApp` injects `GoalDiggerStore` as an `@EnvironmentObject`.

A personal productivity dashboard with Daily / Weekly / Monthly views for tasks, habits, goals, and self-reflection.

---

## Architecture

### State / Data Layer
- `GoalDiggerStore` (`models.swift`) — single `ObservableObject` shared app-wide via `@EnvironmentObject`.
- Persistence via `UserDefaults` (JSON encode/decode). Keys: `gd_tasks`, `gd_habits`, `gd_goals`, `gd_ratings`, `gd_focus`, `gd_routines`.
- No external dependencies, no Combine usage in views — use async/await if needed.
- **"Today" reference:** Always use `GoalDiggerStore.today` (a computed `var today: Date { Calendar.current.startOfDay(for: Date()) }`). Views must never call `Date()` directly — this prevents subtle midnight-boundary bugs.

### Persistence Strategy
- Every mutating function on `GoalDiggerStore` calls a private `save()` method as its last step.
- Additionally, a `scenePhase` `.background` observer in `GoalDiggerApp` calls `save()` as a safety net.
- On **decode failure**: show a full-screen "error" view styled like a cheeky blue Windows BSOD (see `ErrorView` in `theme.swift`). Never silently swallow errors or crash — surface them with personality.

### View Hierarchy
```
GoalDiggerApp
└── ContentView          — tab bar (Daily/Weekly/Monthly) + header + FAB
    ├── DailyView        — quote, morning routine, top 3 priorities, tasks, habits, rate my day, wins
    ├── WeeklyView       — week strip, weekly focus, tasks, 7-day habit grid, rate my week
    └── MonthlyView      — calendar, monthly tasks, short/long-term goals, progress overview, monthly review
```

### Supporting Views
| File | Key views |
|------|-----------|
| `taskViews.swift` | `TaskRowView`, `TaskDetailSheet`, `AddTaskSheet` |
| `widgetViews.swift` | `AddWidgetSheet`, `HabitManagerContent`, `RoutineManagerContent`, `HabitManagerSheet`, `RoutineManagerSheet` |
| `monthyView.swift` | `GoalRowView`, `AddGoalSheet` (defined here alongside `MonthlyView`) |
| `theme.swift` | `GDTheme`, `GoldDivider`, `SectionLabel`, `GDCard`, `ErrorView` (BSOD decode failure screen) |

> `monthyView.swift` has a typo (missing 'l'). **Do not rename** without explicit user confirmation.

---

## Data Models (`models.swift`)

| Model | Key fields |
|-------|-----------|
| `GDTask` | `title`, `period: TaskPeriod`, `priority: TaskPriority`, `category: TaskCategory`, `isCompleted`, `isWin`, `isPinned: Bool`, `notes`, `dueTime` |
| `Habit` | `name`, `icon` (emoji string), `completedDays: Set<String>` (keys: `"yyyy-MM-dd"`) |
| `Goal` | `title`, `category`, `targetValue`, `currentValue`, `unit`, `isLongTerm` |
| `DayRating` | `date`, `score: Int` (1–10), `note` |
| `WeeklyFocus` | `weekStart`, `focusStatement`, `intentions`, `gratitudes`, `wins`, `weekRating: Int` (1–10) |
| `Routine` | `title`, `steps: [RoutineStep]`, `period: RoutinePeriod` |
| `RoutineStep` | `title`, `isCompleted`, `order: Int` |
| `MonthlyReview` | `monthStart: Date`, `highlights: [String]`, `challenges: [String]`, `lessonsLearned: String`, `nextMonthIntentions: [String]`, `overallRating: Int` (1–10) |

### Enums
- `TaskPeriod`: `.daily`, `.weekly`, `.monthly`
- `TaskPriority`: `.high`, `.medium`, `.low` — each has a `.color`
- `TaskCategory`: `.personal`, `.work`, `.health`, `.financial`, `.learning`, `.creative` — each has `.icon` (SF Symbol) and `.color`
- `RoutinePeriod`: `.morning`, `.evening`

---

## Business Logic

### Top 3 Priorities
- Manually pinned by the user via a long-press or pin button on any `GDTask`.
- Stored as `isPinned: Bool` on `GDTask`.
- `DailyView` filters `tasks.filter { $0.isPinned && $0.period == .daily }` and shows the first 3.
- If more than 3 tasks are pinned, display all pinned tasks but show a soft warning label ("You've pinned more than 3 — pick your real top 3").

### Wins
- `isWin` is **automatically set to `true`** when a task's `isCompleted` is toggled to `true`.
- The user can manually un-toggle `isWin` from the task detail sheet if they don't consider it a win.
- Wins appear in the Wins section of `DailyView` and feed into `WeeklyFocus.wins`.

### Rate My Day / Rate My Week
- Both use a **1–10 integer score** (e.g. a horizontal slider snapping to integers, or a row of tappable number buttons).
- Stored in `DayRating.score` and `WeeklyFocus.weekRating` respectively.
- An optional freetext `note` / `wins` field accompanies each rating.

### Weekly Focus
- Created **manually** by the user — no auto-generation.
- One `WeeklyFocus` entry per week, keyed by `weekStart` (Monday-normalised `Date`).
- If no `WeeklyFocus` exists for the current week, show an empty prompt card inviting the user to set one.

### Date & Week Logic
- **Week starts on Sunday.**
- `Calendar.startOfWeek(for:)` extension must set `firstWeekday = 1` (Sunday) explicitly — do not rely on device locale.
- All `"yyyy-MM-dd"` date string keys use `Calendar.current` with a fixed `Locale(identifier: "en_US_POSIX")` formatter to avoid locale-specific formatting bugs.

### Morning Routine
- Backed by `Routine` model with `period: .morning`.
- A default empty morning routine is seeded on first launch alongside sample tasks.
- Steps are reorderable (drag-and-drop) and each step can be checked off daily (reset at midnight using `today` reference).
- Managed via `RoutineManagerSheet` in `widgetViews.swift`.

### Daily Quote
- Sourced from a **hardcoded array of famous boxer quotes** in `theme.swift` (or a dedicated `quotes.swift` file) until a proper quotes dataset is integrated.
- Selected via `quotes.randomElement()` seeded by the day (`Int(today.timeIntervalSince1970 / 86400)`) so the quote stays consistent throughout the day but changes daily.
- Sample quotes to seed the array (add more as found):
  - "Float like a butterfly, sting like a bee." — Muhammad Ali
  - "Everyone has a plan until they get punched in the mouth." — Mike Tyson
  - "It's not about how hard you hit. It's about how hard you can get hit and keep moving forward." — Rocky Balboa (film)
  - "I am the greatest, I said that even before I knew I was." — Muhammad Ali
  - "A champion is someone who gets up when they can't." — Jack Dempsey

---

## Theme (`GDTheme`)

Warm cream / near-black / gold palette. All colors defined as `static let` on `GDTheme`. **Do not refactor or rename theme tokens** — they are used across every view.

| Token | Hex | Use |
|-------|-----|-----|
| `background` | `#F7F5F0` | Screen background |
| `surface` | `#FFFFFF` | Card background |
| `surfaceAlt` | `#F0EDE6` | Inactive controls |
| `primary` | `#1C1C1E` | Main text |
| `secondary` | `#6B6463` | Subtext, labels |
| `gold` | `#C8A96E` | Accent, highlights |
| `goldLight` | `#F0E6CB` | Soft gold background |
| `divider` | `#E0DDD5` | Separators |
| `success` | `#5C8B6E` | Completion, done states |
| `danger` | `#C0504D` | Destructive actions |

### Typography helpers
- `GDTheme.serifFont(_ size)` — Georgia
- `GDTheme.sansFont(_ size, weight:)` — system sans
- `GDTheme.monoFont(_ size)` — system monospaced
- `GDTheme.titleFont(_ size)` — Georgia large

### Reusable components
- `GDCard { content }` — white card with shadow, 12pt corner radius
- `SectionLabel(text:)` — gold left-bar + uppercase tracked label
- `GoldDivider()` — 1pt gold horizontal rule
- `ErrorView` — full-screen BSOD-style decode failure screen (blue background, white mono text, cheeky error code)

---

## Feature Status

| Feature | Status |
|---------|--------|
| Tab bar + ContentView shell | Done |
| DailyView layout | Done |
| WeeklyView layout | Done |
| MonthlyView layout | Done |
| Task CRUD (add / complete / delete) | Done |
| Task swipe actions | Done |
| Habit tracking + 7-day grid | Done |
| Rate My Day (1–10) | Done |
| Top 3 Priorities (pinning) | In Progress |
| Morning Routine manager | In Progress |
| Weekly Focus editor | In Progress |
| Monthly Review form | Planned |
| Win auto-set on task complete | Planned |
| Daily quote (boxer array) | Planned |
| BSOD decode failure screen | Planned |
| Goal progress tracking | Planned |

> Keep this table updated as features land. Treat Planned features as **not yet implemented** — do not assume their code exists.

---

## Claude-Specific Instructions

### Where things live
- **All new models and enums** -> `models.swift` only.
- **All new reusable UI components** -> `theme.swift`.
- **View-specific subviews** -> co-locate in the relevant view file (e.g. a new DailyView card goes in `dailyView.swift`).
- **New manager sheets** -> `widgetViews.swift`.

### What NOT to touch
- Do **not** rename or refactor `GDTheme` color/font tokens.
- Do **not** rename `monthyView.swift` (typo is intentional preservation until confirmed otherwise).
- Do **not** introduce external package dependencies without asking first.
- Do **not** switch persistence from `UserDefaults` to CoreData/SwiftData without explicit instruction.

### How to add a new card/section to a view
1. Create a private subview `struct MyNewCard: View` at the bottom of the relevant view file.
2. Wrap content in `GDCard { }`.
3. Use `SectionLabel(text:)` for the section header.
4. Add the corresponding model field to `GoalDiggerStore` in `models.swift`.
5. Add the `UserDefaults` key to the keys comment block at the top of `models.swift`.
6. Call `save()` in every mutating method that touches the new model.

### General patterns
- Prefer `@EnvironmentObject var store: GoalDiggerStore` over passing store as a parameter.
- Use `store.today` for all "current day" references — never `Date()` directly in views.
- Sheet presentations use `.sheet(isPresented:)` with a dedicated `@State var showX = false` bool.
- Destructive confirmations use `.confirmationDialog` not `Alert`.
- All date string keys use the fixed `en_US_POSIX` locale formatter (see `models.swift` formatter helper).

---

## File Map

```
Dashboard/Dashboard/
  goalDiggerApp.swift   — @main, injects GoalDiggerStore, scenePhase save observer
  ContentView.swift     — root view, tab switching, FAB
  dailyView.swift       — DailyView + all daily card subviews
  weeklyView.swift      — WeeklyView + weekly focus editor
  monthyView.swift      — MonthlyView, GoalRowView, AddGoalSheet  (typo in filename — do not rename)
  taskViews.swift       — TaskRowView, TaskDetailSheet, AddTaskSheet
  widgetViews.swift     — AddWidgetSheet, habit/routine managers
  models.swift          — all models, enums, GoalDiggerStore
  theme.swift           — GDTheme, Color(hex:), GDCard, SectionLabel, GoldDivider, ErrorView
```
