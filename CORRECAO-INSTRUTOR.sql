-- AUTOESCOLA PREFERÊNCIA — CORREÇÃO ÁREA DO INSTRUTOR
-- Execute este arquivo no Supabase SQL Editor antes de testar instrutor.html.

create or replace function public.validar_login_instrutor(
  p_usuario text,
  p_senha text
)
returns table (
  id uuid,
  nome text,
  telefone text,
  categoria text,
  status text
)
language sql
security definer
set search_path = public
as $$
  select
    i.id,
    i.nome,
    i.telefone,
    i.categoria,
    i.status
  from public.instrutores i
  where lower(split_part(trim(i.nome), ' ', 1)) = lower(trim(p_usuario))
    and i.senha = p_senha
    and i.status = 'Ativo'
  limit 1;
$$;

grant execute on function public.validar_login_instrutor(text,text)
to anon, authenticated;


create or replace function public.listar_aulas_instrutor(
  p_instrutor_id uuid
)
returns table (
  id uuid,
  data date,
  horario time,
  tipo text,
  status text,
  aluno_nome text,
  veiculo_nome text
)
language sql
security definer
set search_path = public
as $$
  select
    a.id,
    a.data,
    a.horario,
    a.tipo,
    a.status,
    al.nome as aluno_nome,
    coalesce(v.modelo, v.identificacao, 'Veículo') as veiculo_nome
  from public.agendamentos a
  left join public.alunos al on al.id = a.aluno_id
  left join public.veiculos v on v.id = a.veiculo_id
  where a.instrutor_id = p_instrutor_id
  order by a.data asc, a.horario asc;
$$;

grant execute on function public.listar_aulas_instrutor(uuid)
to anon, authenticated;


create or replace function public.atualizar_status_aula_instrutor(
  p_instrutor_id uuid,
  p_agendamento_id uuid,
  p_status text
)
returns boolean
language plpgsql
security definer
set search_path = public
as $$
begin
  if p_status not in ('Realizada','Falta') then
    raise exception 'Status não permitido';
  end if;

  update public.agendamentos
     set status = p_status,
         atualizado_em = now()
   where id = p_agendamento_id
     and instrutor_id = p_instrutor_id
     and status = 'Confirmada';

  return found;
end;
$$;

grant execute on function public.atualizar_status_aula_instrutor(uuid,uuid,text)
to anon, authenticated;