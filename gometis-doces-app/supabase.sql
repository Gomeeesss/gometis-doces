-- GOMETIS: banco de dados na nuvem (Supabase)
-- Cole tudo isto no "SQL Editor" do Supabase e clique em Run.

-- Uma linha por cliente, com todos os dados do app dele.
create table if not exists public.dados (
  user_id uuid primary key references auth.users(id) on delete cascade,
  conteudo jsonb not null default '{}'::jsonb,
  atualizado timestamptz not null default now()
);

-- Segurança: cada cliente só enxerga e altera a PRÓPRIA linha.
alter table public.dados enable row level security;

create policy "ler os proprios dados" on public.dados
  for select using ((select auth.uid()) = user_id);
create policy "criar os proprios dados" on public.dados
  for insert with check ((select auth.uid()) = user_id);
create policy "alterar os proprios dados" on public.dados
  for update using ((select auth.uid()) = user_id) with check ((select auth.uid()) = user_id);
create policy "apagar os proprios dados" on public.dados
  for delete using ((select auth.uid()) = user_id);
