# Supabase Local Dev

```bash
supabase start
supabase db reset        # applies migrations + seed
supabase gen types dart --local > lib/core/supabase_types.dart
```

Migrations live in `supabase/migrations/` and are applied in filename order.
**Every** table must have RLS enabled and a policy scoping to `auth.uid()`.
