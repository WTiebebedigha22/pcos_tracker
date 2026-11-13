# Offline Sync Design (DRAFT)

**Strategy:** last-write-wins by `updated_at` server timestamp, with client-side queue.

1. All writes go to Hive first, then enqueued in `outbox` box.
2. On connectivity regain (`connectivity_plus`), drain outbox → Supabase.
3. Server rows carry `updated_at`; client compares on pull, server wins on conflict.
4. Deletions use soft-delete (`deleted_at`) to reconcile across devices.
5. UI shows a "Syncing…" chip while outbox is non-empty.

**Open questions:** conflict UI for true concurrent edits, retry backoff, max outbox size.
