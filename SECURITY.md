# Security Policy

## Reporting a Vulnerability
Email security@lunora.app (replace) — do **not** open public issues for security bugs.

## Data Handling
- Menstrual, symptom, and mental-health data are **sensitive**.
- All Supabase tables MUST have Row-Level Security enabled with `auth.uid() = user_id`.
- `.env` is never committed; secrets live in GitHub Actions secrets / EAS secrets.
