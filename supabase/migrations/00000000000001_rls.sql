-- Row-Level Security. Every user-owned table gets `user_id = auth.uid()`.
alter table profiles       enable row level security;
alter table cycles         enable row level security;
alter table symptoms       enable row level security;
alter table medications    enable row level security;
alter table lifestyle_logs enable row level security;

-- profiles: user can read/update own row
create policy "profiles self read"   on profiles for select using (id = auth.uid());
create policy "profiles self update" on profiles for update using (id = auth.uid());
create policy "profiles self insert" on profiles for insert with check (id = auth.uid());

-- Generic pattern for user-owned tables
do $$
declare t text;
begin
  foreach t in array array['cycles','symptoms','medications','lifestyle_logs']
  loop
    execute format(
      'create policy "%1$s owner select" on %1$s for select using (user_id = auth.uid());', t);
    execute format(
      'create policy "%1$s owner insert" on %1$s for insert with check (user_id = auth.uid());', t);
    execute format(
      'create policy "%1$s owner update" on %1$s for update using (user_id = auth.uid());', t);
    execute format(
      'create policy "%1$s owner delete" on %1$s for delete using (user_id = auth.uid());', t);
  end loop;
end $$;
