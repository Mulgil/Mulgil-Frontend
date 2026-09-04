# Mulgil Design System

## 1. Atmosphere & Identity

Mulgil is a calm academic workspace: dark-navy actions anchor a light, cool-gray canvas while teal marks progress and direct interaction. The recognizable pattern is a quiet, bordered surface rather than elevation-heavy cards, so dense study information stays legible.

## 2. Color

| Role | Flutter token | Value | Usage |
|---|---|---:|---|
| Canvas | `AppColors.bg` | `#F2F3F4` | Screen background |
| Surface | `AppColors.surface` | `#FFFFFF` | Sheets, cards, timetable |
| Alt surface | `AppColors.surfaceAlt` | `#F1F7F8` | Inputs and quiet notices |
| Primary text | `AppColors.ink` | `#141A1F` | Headings and body |
| Muted text | `AppColors.ink60` | `#5E676D` | Supporting copy |
| Border | `AppColors.border` | `#E6E9EC` | Surface and input outlines |
| Primary action | `AppColors.navy` | `#0B2A42` | Main buttons and selected state |
| Interactive accent | `AppColors.teal` | `#00C9D4` | Focus and progress |
| Error | `AppColors.coral` | `#FF6B4A` | Validation and destructive actions |
| Success | `AppColors.green` | `#0F9D58` | Positive status |

Use only `AppColors` tokens in UI code. Accent colors communicate state or an action; they are not decoration.

## 3. Typography

- Primary family: Noto Sans KR via `GoogleFonts.notoSansKr`; logo: Nunito.
- Page headings: `AppTextStyles.h1` (24/800) and `h2` (18/800).
- Component headings: `AppTextStyles.h3` (16/700).
- Body: `AppTextStyles.body` (14/400); compact supporting copy: `bodySmall` (12/400) or `caption` (11/400).
- Form labels and actions use 12–15px, 600–700 weight, matching existing controls.

## 4. Spacing & Layout

The base unit is 4px. Existing screens use 8px for compact adjacency, 12–16px between form controls, 20px for sheet/page inset, and 24–28px between sections. Content uses 20px mobile padding and switches to tablet layout above 768px via `BuildContextX.isTablet`.

## 5. Components

### `MulgilButton`

- Full-width navy primary action with 18px radius; disabled when its callback is null.
- Uses an `InkWell` tap state and remains the submit control for forms.

### `MulgilCard` and bordered surfaces

- White surface, 18px radius, and `AppColors.border` outline; no elevation.
- Interactive cards use `InkWell`; static cards do not pretend to be tappable.

### Bottom sheets and form controls

- `showMulgilSheet` provides the white, rounded sheet container.
- Inputs use the theme's alternate surface and teal focus outline. Choice chips select weekdays; outlined buttons open native time pickers.
- Course time rows show each selected weekday's independent start and end values. They must remain readable at narrow widths and scroll instead of overflowing when many weekdays are selected.

## 6. Motion & Interaction

Use Material's existing press/focus feedback. The existing toggle uses a 200ms state transition. New course-time controls introduce no decorative motion; each button opens a native picker and every selected weekday receives visible editable values.

## 7. Depth & Surface

Strategy: borders-only. `AppColors.surface` and `AppColors.surfaceAlt` establish hierarchy, with `AppColors.border` separating cards, inputs, and timetable cells. New work must not add shadows.

## 8. Accessibility Constraints & Accepted Debt

- Target WCAG 2.2 AA: visible focus, adequate text contrast, keyboard/touch reachability, and clear Korean validation messages.
- Course registration must expose distinct controls per selected weekday so a learner can inspect and change each time without relying on a hidden shared value.
- Accepted debt: none for this change.
