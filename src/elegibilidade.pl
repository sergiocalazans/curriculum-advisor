% Camada 2: elegibilidade, pendências, histórico e situação acadêmica.
% A base é carregada pelo caminho relativo a este arquivo.
:- ensure_loaded('curriculum.pl').
:- use_module(library(lists)).

% Reconhece ou enumera alunos, inclusive aqueles sem histórico de aprovação.
aluno_cadastrado(Aluno) :- aluno(Aluno, _, _).

% Exige todos os pré-requisitos diretos; sem requisitos, forall/2 é verdadeiro.
% O cadastro de aluno e disciplina é verificado antes da consulta ao histórico.
prerequisitos_ok(Aluno, Disciplina) :-
    aluno_cadastrado(Aluno), disciplina(Disciplina, _, _, _),
    forall(prerequisito(Disciplina, Requisito), cursou(Aluno, Requisito)).

% Só libera disciplinas não concluídas para alunos regulares.
% Aluno e disciplina já estão instanciados quando a negação por falha é usada.
pode_cursar(Aluno, Disciplina) :-
    aluno(Aluno, _, regular), disciplina(Disciplina, _, _, _),
    prerequisitos_ok(Aluno, Disciplina), \+ cursou(Aluno, Disciplina).

% Lista ordenada e sem duplicatas; aluno cadastrado sem opções recebe [].
disciplinas_liberadas(Aluno, Lista) :-
    aluno_cadastrado(Aluno), findall(D, pode_cursar(Aluno, D), Disciplinas), sort(Disciplinas, Lista).

% Pendências de formatura são apenas obrigatórias, mesmo para aluno trancado.
disciplinas_pendentes(Aluno, Lista) :-
    aluno_cadastrado(Aluno),
    findall(D, (disciplina(D, obrigatoria, _, _), \+ cursou(Aluno, D)), Disciplinas), sort(Disciplinas, Lista).

% Normaliza o histórico, removendo aprovações repetidas antes da soma de créditos.
historico_aluno(Aluno, Historico) :-
    aluno_cadastrado(Aluno), findall(D, cursou(Aluno, D), Disciplinas), sort(Disciplinas, Historico).

% Soma o histórico normalizado; aluno cadastrado sem aprovações recebe zero.
creditos_cursados(Aluno, Total) :-
    historico_aluno(Aluno, Historico), creditos_disciplinas(Historico, Total).

% Soma recursiva de uma lista de disciplinas; a lista vazia vale zero.
% Este auxiliar pressupõe lista sem duplicatas, preparada pelo chamador.
creditos_disciplinas([], 0).
creditos_disciplinas([Disciplina|Disciplinas], Total) :-
    disciplina(Disciplina, _, Creditos, _), creditos_disciplinas(Disciplinas, Restante), Total is Creditos + Restante.

% Para alunos regulares, atraso tem prioridade sobre aprovações adiantadas.
% A classificação é informativa e não bloqueia a elegibilidade.
situacao_aluno(Aluno, Situacao) :-
    aluno(Aluno, Semestre, regular),
    ( \+ em_dia(Aluno, Semestre) -> Situacao = atrasado
    ; adiantou_disciplina(Aluno, Semestre) -> Situacao = adiantado
    ; Situacao = no_ritmo ).

% Estar em dia exige todas as obrigatórias de períodos sugeridos anteriores.
em_dia(Aluno, Semestre) :-
    aluno(Aluno, Semestre, regular),
    forall((disciplina(D, obrigatoria, _, Sugerido), Sugerido < Semestre), cursou(Aluno, D)).

% Aprovação do período atual ou posterior caracteriza adiantamento neste modelo.
adiantou_disciplina(Aluno, Semestre) :-
    aluno(Aluno, Semestre, regular), cursou(Aluno, D), disciplina(D, _, _, Sugerido), Sugerido >= Semestre.
