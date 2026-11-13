# Lunora Style Guide

## Spacing
Use `DesignTokens.space` — never hardcode. Scale: 2 / 4 / 8 / 12 / 16 / 24 / 32 / 48.

## Radius
4 / 8 / 12 / 16 / 24 / pill.

## Motion
- fast 150ms — micro feedback
- base 250ms — page/state transitions
- slow 400ms — reveals
- Respect `ReducedMotion.enabled(context)`

## Color
- Semantic layer (`SemanticColors`) for health states — not raw Material colors
- Verify contrast ≥4.5:1 for body, ≥3:1 for large text
- The "soft pink" palette is a known accessibility risk; test both themes

## Typography
Poppins. Scale from `AppTheme._typeScale`. Do not override `fontSize` inline.

## Components
- Buttons: `AppButton` (variants: primary, secondary, ghost, danger)
- Cards: `AppCard`
- Chips: `AppChip`
- Sheets: `AppSheet.show()`
- Confirmation: `ConfirmDialog.show()` (destructive requires this)
- Toast: `Toast.show()` / `Toast.undo()`

## Screen checklist (every screen)
- [ ] Handles loading / empty / error / offline
- [ ] Loading uses skeleton for lists, spinner only for actions
- [ ] Empty state has icon + title + optional CTA
- [ ] Icon-only buttons wrapped in `AccessibleIconButton`
- [ ] Interactive widgets ≥48dp
- [ ] Respects textScaler (no fixed-height text rows)
- [ ] Charts include `ChartSummary`
- [ ] Destructive actions go through `ConfirmDialog`
- [ ] Prediction/dosage screens include `MedicalDisclaimer`
