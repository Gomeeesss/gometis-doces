-- Bolso em Dia: banco de dados.
-- Como usar: Supabase > SQL Editor > New query > cole tudo > Run. Pode rodar mais de uma vez.

-- 1. Dados de cada pessoa: um registro de configurações ("meta") e um registro por mês ("tx-AAAA-MM").
create table if not exists public.bolso_docs (
  user_id    uuid        not null references auth.users(id) on delete cascade,
  doc_id     text        not null check (doc_id ~ '^(meta|tx-[0-9]{4}-[0-9]{2})$'),
  conteudo   jsonb       not null,
  atualizado timestamptz not null default now(),
  primary key (user_id, doc_id),
  constraint bolso_docs_tamanho check (pg_column_size(conteudo) < 1500000)
);

-- 2. Cada pessoa só vê e altera os próprios dados.
alter table public.bolso_docs enable row level security;

drop policy if exists "bolso: ler os proprios dados"    on public.bolso_docs;
drop policy if exists "bolso: criar os proprios dados"  on public.bolso_docs;
drop policy if exists "bolso: alterar os proprios dados" on public.bolso_docs;
drop policy if exists "bolso: apagar os proprios dados" on public.bolso_docs;

create policy "bolso: ler os proprios dados" on public.bolso_docs
  for select to authenticated using ((select auth.uid()) = user_id);
create policy "bolso: criar os proprios dados" on public.bolso_docs
  for insert to authenticated with check ((select auth.uid()) = user_id);
create policy "bolso: alterar os proprios dados" on public.bolso_docs
  for update to authenticated using ((select auth.uid()) = user_id) with check ((select auth.uid()) = user_id);
create policy "bolso: apagar os proprios dados" on public.bolso_docs
  for delete to authenticated using ((select auth.uid()) = user_id);

-- 3. "Excluir minha conta": apaga os dados e o login da própria pessoa (direito previsto na LGPD).
create or replace function public.excluir_minha_conta()
returns void
language plpgsql
security definer
set search_path = ''
as $$
begin
  if auth.uid() is null then
    raise exception 'not authenticated';
  end if;
  delete from public.bolso_docs where user_id = auth.uid();
  delete from auth.users where id = auth.uid();
end;
$$;

revoke all on function public.excluir_minha_conta() from public, anon;
grant execute on function public.excluir_minha_conta() to authenticated;
