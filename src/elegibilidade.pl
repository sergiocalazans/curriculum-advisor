:- ensure_loaded('curriculum.pl').
:- use_module(library(lists)).

% Enumera alunos antes de usar negacao por falha.
aluno_cadastrado(Aluno) :- aluno(Aluno, _, _).

prerequisitos_ok(Aluno, Disciplina) :-
    aluno_cadastrado(Aluno), disciplina(Disciplina, _, _, _),
    forall(prerequisito(Disciplina, Requisito), cursou(Aluno, Requisito)).

pode_cursar(Aluno, Disciplina) :-
    aluno(Aluno, _, regular), disciplina(Disciplina, _, _, _),
    prerequisitos_ok(Aluno, Disciplina), \+ cursou(Aluno, Disciplina).

disciplinas_liberadas(Aluno, Lista) :-
    aluno_cadastrado(Aluno), findall(D, pode_cursar(Aluno, D), Disciplinas), sort(Disciplinas, Lista).

disciplinas_pendentes(Aluno, Lista) :-
    aluno_cadastrado(Aluno),
    findall(D, (disciplina(D, obrigatoria, _, _), \+ cursou(Aluno, D)), Disciplinas), sort(Disciplinas, Lista).

historico_aluno(Aluno, Historico) :-
    aluno_cadastrado(Aluno), findall(D, cursou(Aluno, D), Disciplinas), sort(Disciplinas, Historico).

creditos_cursados(Aluno, Total) :-
    historico_aluno(Aluno, Historico), creditos_disciplinas(Historico, Total).

% A soma nao depende de efeitos colaterais nem conta fatos de historico repetidos.
creditos_disciplinas([], 0).
creditos_disciplinas([Disciplina|Disciplinas], Total) :-
    disciplina(Disciplina, _, Creditos, _), creditos_disciplinas(Disciplinas, Restante), Total is Creditos + Restante.

situacao_aluno(Aluno, Situacao) :-
    aluno(Aluno, Semestre, regular),
    ( \+ em_dia(Aluno, Semestre) -> Situacao = atrasado
    ; adiantou_disciplina(Aluno, Semestre) -> Situacao = adiantado
    ; Situacao = no_ritmo ).

em_dia(Aluno, Semestre) :-
    aluno(Aluno, Semestre, regular),
    forall((disciplina(D, obrigatoria, _, Sugerido), Sugerido < Semestre), cursou(Aluno, D)).

adiantou_disciplina(Aluno, Semestre) :-
    aluno(Aluno, Semestre, regular), cursou(Aluno, D), disciplina(D, _, _, Sugerido), Sugerido >= Semestre.
