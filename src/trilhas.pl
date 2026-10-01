:- ensure_loaded('elegibilidade.pl').

limite_semestres(12).

% Visitados limita cada caminho. A aresta final pode voltar a origem para detectar ciclos.
prerequisito_transitivo(Disciplina, Ancestral) :-
    disciplina(Disciplina, _, _, _), disciplina(Ancestral, _, _, _),
    once(caminho_prerequisito(Disciplina, Ancestral, [Disciplina])).

caminho_prerequisito(Disciplina, Ancestral, _) :- prerequisito(Disciplina, Ancestral).
caminho_prerequisito(Disciplina, Ancestral, Visitados) :-
    prerequisito(Disciplina, Proxima), \+ memberchk(Proxima, Visitados),
    caminho_prerequisito(Proxima, Ancestral, [Proxima|Visitados]).

existe_ciclo(Disciplina) :- prerequisito_transitivo(Disciplina, Disciplina).

% Rejeita inconsistencias antes da busca; nao modifica a base de fatos.
base_consistente :-
    findall(D, disciplina(D, _, _, _), Nomes), sort(Nomes, Unicos), same_length(Nomes, Unicos),
    forall(disciplina(D, Tipo, Creditos, Semestre),
        (atom(D), memberchk(Tipo, [obrigatoria, eletiva]), integer(Creditos), Creditos >= 0, integer(Semestre), Semestre >= 1)),
    forall(prerequisito(D, R), (disciplina(D, _, _, _), disciplina(R, _, _, _))),
    forall(aluno(A, Semestre, Status), (atom(A), integer(Semestre), Semestre >= 1, memberchk(Status, [regular, trancado]))),
    forall(cursou(A, D), (aluno_cadastrado(A), disciplina(D, _, _, _))),
    \+ existe_ciclo(_).

trilha_valida(Aluno, MaxCreditos, Trilha) :-
    limite_semestres(Limite), trilha_valida(Aluno, MaxCreditos, Limite, Trilha).

% Versao adicional: permite um limite menor, sempre respeitando o teto de 12.
trilha_valida(Aluno, MaxCreditos, MaxSemestres, Trilha) :-
    integer(MaxCreditos), MaxCreditos > 0, integer(MaxSemestres), MaxSemestres >= 0,
    limite_semestres(Teto), MaxSemestres =< Teto, aluno(Aluno, _, regular), base_consistente,
    historico_aluno(Aluno, Historico), disciplinas_pendentes(Aluno, Pendentes),
    disciplinas_necessarias(Pendentes, Historico, Necessarias),
    forall(member(D, Necessarias), (disciplina(D, _, C, _), C =< MaxCreditos)),
    planejar_semestres(Necessarias, Historico, MaxCreditos, MaxSemestres, Trilha).

% Inclui eletivas somente quando sao pre-requisitos de uma obrigatoria pendente.
disciplinas_necessarias(Pendentes, Historico, Necessarias) :-
    findall(R, (member(D, Pendentes), prerequisito_transitivo(D, R), \+ memberchk(R, Historico)), Requisitos),
    append(Pendentes, Requisitos, Todas), sort(Todas, Necessarias).

planejar_semestres([], _, _, _, []).
planejar_semestres([Pendente|Pendentes], Historico, MaxCreditos, Restantes, [Semestre|Trilha]) :-
    Restantes > 0, Necessarias = [Pendente|Pendentes],
    creditos_disciplinas(Necessarias, Total), Total =< MaxCreditos * Restantes,
    forall(member(D, Necessarias), (profundidade_pendente(D, Historico, Profundidade), Profundidade =< Restantes)),
    findall(D, (member(D, Necessarias), requisitos_no_historico(D, Historico)), Elegiveis),
    ordenar_elegiveis(Elegiveis, Ordenadas), selecionar_semestre(Ordenadas, MaxCreditos, Selecionadas),
    Selecionadas = [_|_], sort(Selecionadas, Semestre),
    subtract(Necessarias, Semestre, NovasPendentes), append(Semestre, Historico, NovoHistorico),
    Proximos is Restantes - 1, planejar_semestres(NovasPendentes, NovoHistorico, MaxCreditos, Proximos, Trilha).

requisitos_no_historico(Disciplina, Historico) :-
    forall(prerequisito(Disciplina, R), memberchk(R, Historico)).

% Uma cadeia de K disciplinas ainda nao cursadas exige no minimo K semestres.
profundidade_pendente(Disciplina, Historico, Profundidade) :-
    findall(P, (prerequisito(Disciplina, R), \+ memberchk(R, Historico), profundidade_pendente(R, Historico, P)), Ps),
    max_list([0|Ps], Maior), Profundidade is Maior + 1.

% Prefere periodos sugeridos anteriores e, dentro deles, creditos maiores. Nao elimina alternativas.
ordenar_elegiveis(Disciplinas, Ordenadas) :-
    findall((Semestre-Chave)-D, (member(D, Disciplinas), disciplina(D, _, C, Semestre), Chave is -C), Pares),
    keysort(Pares, Classificados), valores_pares(Classificados, Ordenadas).

valores_pares([], []).
valores_pares([_-D|Pares], [D|Disciplinas]) :- valores_pares(Pares, Disciplinas).

selecionar_semestre([], _, []).
selecionar_semestre([D|Disciplinas], Disponiveis, [D|Selecionadas]) :-
    disciplina(D, _, Creditos, _), Creditos =< Disponiveis, Restantes is Disponiveis - Creditos,
    selecionar_semestre(Disciplinas, Restantes, Selecionadas).
selecionar_semestre([_|Disciplinas], Disponiveis, Selecionadas) :-
    selecionar_semestre(Disciplinas, Disponiveis, Selecionadas).

% Coleta um unico lote de ate N solucoes, sem tentar materializar o espaco inteiro.
trilhas_limitadas(Aluno, MaxCreditos, Quantidade, Trilhas) :-
    aluno(Aluno, _, regular), integer(MaxCreditos), MaxCreditos > 0, integer(Quantidade), Quantidade > 0,
    once(findnsols(Quantidade, Trilha, trilha_valida(Aluno, MaxCreditos, Trilha), Trilhas)).
