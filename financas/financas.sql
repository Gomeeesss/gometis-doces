-- Tabela do app Controle Financeiro (uma linha por pessoa).
-- Cole no SQL Editor do Supabase e clique em Run.
create table if not exists public.financas (
  user_id uuid primary key references auth.users(id) on delete cascade,
  conteudo jsonb not null default '{}'::jsonb,
  atualizado timestamptz not null default now()
);
alter table public.financas enable row level security;
create policy "financas: ler os proprios dados" on public.financas
  for select using ((select auth.uid()) = user_id);
create policy "financas: criar os proprios dados" on public.financas
  for insert with check ((select auth.uid()) = user_id);
create policy "financas: alterar os proprios dados" on public.financas
  for update using ((select auth.uid()) = user_id) with check ((select auth.uid()) = user_id);
create policy "financas: apagar os proprios dados" on public.financas
  for delete using ((select auth.uid()) = user_id);
