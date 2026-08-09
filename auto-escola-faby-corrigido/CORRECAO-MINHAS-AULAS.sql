-- AUTOESCOLA PREFERÊNCIA — CORREÇÃO MINHAS AULAS
-- Execute TODO este arquivo no SQL Editor do Supabase e clique em Run.

create or replace function public.listar_aulas_aluno(p_aluno_id uuid)
returns table (
  id uuid,
  data date,
  horario time,
  tipo text,
  status text,
  instrutor_nome text,
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
    i.nome as instrutor_nome,
    coalesce(v.modelo, v.placa, 'Veículo') as veiculo_nome
  from public.agendamentos a
  left join public.instrutores i on i.id = a.instrutor_id
  left join public.veiculos v on v.id = a.veiculo_id
  where a.aluno_id = p_aluno_id
  order by a.data asc, a.horario asc;
$$;

grant execute on function public.listar_aulas_aluno(uuid) to anon, authenticated;

-- TESTE OPCIONAL (troque pelo UUID do aluno, se quiser testar no SQL):
-- select * from public.listar_aulas_aluno('UUID-DO-ALUNO');
