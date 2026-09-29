% ==========================================
% CONSULTAS INICIAIS DE VALIDAÇÃO
% ==========================================

:- use_module(library(plunit)).
:- ensure_loaded('../src/elegibilidade.pl').

:- begin_tests(curriculum).

% Verifica se existem disciplinas cadastradas.
test(disciplinas_cadastradas) :-
    aggregate_all(count, disciplina(_, _, _, _), Total),
    Total >= 20.

% Verifica se existem disciplinas em pelo menos 6 periodos.
test(periodos_cadastrados) :-
    setof(Semestre,
          N^T^C^disciplina(N, T, C, Semestre),
          Semestres),
    length(Semestres, Total),
    Total >= 6.

% Verifica se existem pelo menos 3 disciplinas eletivas.
test(disciplinas_eletivas) :-
    findall(Nome,
            disciplina(Nome, eletiva, _, _),
            Eletivas),
    length(Eletivas, Total),
    Total >= 3.

% Verifica os historicos dos tres alunos.
test(alunos_cadastrados) :-
    cursou(ana, _),
    cursou(bruno, _),
    cursou(carla, _).

% Verifica um pre-requisito direto.
test(prerequisito_direto) :-
    prerequisito(
        programacao_imperativa,
        algoritmos_programacao
    ).

% Verifica se todos os pre-requisitos cadastrados
% correspondem a disciplinas existentes.
test(integridade_prerequisitos) :-
    forall(
        prerequisito(Disciplina, Requisito),
        (
            disciplina(Disciplina, _, _, _),
            disciplina(Requisito, _, _, _)
        )
    ).

:- end_tests(curriculum).


:- begin_tests(elegibilidade).

% Verifica se Ana possui disciplinas pendentes.
test(pendentes_ana) :-
    disciplinas_pendentes(ana, Lista),
    Lista \= [].

% Verifica se uma disciplina ja cursada
% nao aparece entre as pendentes.
test(disciplina_cursada_nao_pendente) :-
    disciplinas_pendentes(bruno, Lista),
    \+ member(algoritmos_programacao, Lista).

% Verifica se Carla ainda possui
% arquitetura de banco de dados pendente.
test(pendente_carla) :-
    disciplinas_pendentes(carla, Lista),
    member(arquitetura_banco_dados, Lista).

% Verifica se disciplinas liberadas
% nao incluem disciplinas ja cursadas.
test(liberadas_nao_cursadas) :-
    disciplinas_liberadas(bruno, Lista),
    forall(
        member(Disciplina, Lista),
        \+ cursou(bruno, Disciplina)
    ).

% Verifica a ordenacao e ausencia de duplicatas.
test(resultados_ordenados) :-
    disciplinas_pendentes(carla, Lista),
    sort(Lista, Lista).

% Verifica o retorno de listas.
test(retorno_listas) :-
    disciplinas_liberadas(ana, Liberadas),
    disciplinas_pendentes(ana, Pendentes),
    is_list(Liberadas),
    is_list(Pendentes).

:- end_tests(elegibilidade).