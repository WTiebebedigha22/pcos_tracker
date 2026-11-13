-- Baseline schema for Lunora. Review before applying.
create extension if not exists "pgcrypto";

-- Users are managed by Supabase Auth (auth.users). We keep a public profile.
create table if not exists profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  display_name text,
  birth_year int,
  diagnosis_status text, -- 'diagnosed' | 'suspected' | 'unsure'
  created_at timestamptz default now()
);

create table if not exists cycles (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  start_date date not null,
  end_date date,
  flow_intensity smallint,  -- 0..3
  notes text,
  created_at timestamptz default now()
);
create index on cycles (user_id, start_date desc);

create table if not exists symptoms (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  logged_on date not null,
  symptom_key text not null,   -- 'acne' | 'fatigue' | 'hair_loss' | ...
  severity smallint,           -- 0..3
  created_at timestamptz default now()
);
create index on symptoms (user_id, logged_on desc);

create table if not exists medications (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  name text not null,
  dosage text,
  schedule jsonb,              -- reminder config
  active boolean default true,
  created_at timestamptz default now()
);

create table if not exists lifestyle_logs (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  logged_on date not null,
  water_ml int,
  sleep_minutes int,
  exercise_minutes int,
  weight_kg numeric(5,2),
  created_at timestamptz default now()
);
