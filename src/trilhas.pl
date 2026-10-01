% Camada 3: dependências transitivas, validação da base e geração de trilhas.
:- ensure_loaded('elegibilidade.pl').

% Teto de segurança para a quantidade de semestres gerados, não para os sugeridos.
limite_semestres(12).

% Enumera pares cadastrados e encontra pré-requisitos diretos ou indiretos.
% once/1 evita várias provas do mesmo par sem eliminar os outros ancestrais.
prerequisito_transitivo(Disciplina, Ancestral) :-
    disciplina(Disciplina, _, _, _), disciplina(Ancestral, _, _, _),
    once(caminho_prerequisito(Disciplina, Ancestral, [Disciplina])).

% O caso direto pode fechar um ciclo; a recursão evita revisitar vértices.
caminho_prerequisito(Disciplina, Ancestral, _) :- prerequisito(Disciplina, Ancestral).
caminho_prerequisito(Disciplina, Ancestral, Visitados) :-
    prerequisito(Disciplina, Proxima), \+ memberchk(Proxima, Visitados),
    caminho_prerequisito(Proxima, Ancestral, [Proxima|Visitados]).

% Há ciclo nesta disciplina quando um caminho de dependências volta à origem.
existe_ciclo(Disciplina) :- prerequisito_transitivo(Disciplina, Disciplina).

% Verifica disciplinas únicas, atributos válidos, referências existentes e ciclos.
% O histórico é autoritativo: aqui não se verifica a ordem das aprovações.
base_consistente :-
    findall(D, disciplina(D, _, _, _), Nomes), sort(Nomes, Unicos), same_length(Nomes, Unicos),
    forall(disciplina(D, Tipo, Creditos, Semestre),
        (atom(D), memberchk(Tipo, [obrigatoria, eletiva]), integer(Creditos), Creditos >= 0, integer(Semestre), Semestre >= 1)),
    forall(prerequisito(D, R), (disciplina(D, _, _, _), disciplina(R, _, _, _))),
    forall(aluno(A, Semestre, Status), (atom(A), integer(Semestre), Semestre >= 1, memberchk(Status, [regular, trancado]))),
    forall(cursou(A, D), (aluno_cadastrado(A), disciplina(D, _, _, _))),
    \+ existe_ciclo(_).

% Interface principal: gera uma trilha com no máximo o teto de 12 semestres.
trilha_valida(Aluno, MaxCreditos, Trilha) :-
    limite_semestres(Limite), trilha_valida(Aluno, MaxCreditos, Limite, Trilha).

% Permite um limite de zero a 12; zero só atende quem não tem pendências.
% A busca recebe histórico e pendências em listas, sem alterar os fatos da base.
trilha_valida(Aluno, MaxCreditos, MaxSemestres, Trilha) :-
    integer(MaxCreditos), MaxCreditos > 0, integer(MaxSemestres), MaxSemestres >= 0,
    limite_semestres(Teto), MaxSemestres =< Teto, aluno(Aluno, _, regular), base_consistente,
    historico_aluno(Aluno, Historico), disciplinas_pendentes(Aluno, Pendentes),
    disciplinas_necessarias(Pendentes, Historico, Necessarias),
    forall(member(D, Necessarias), (disciplina(D, _, C, _), C =< MaxCreditos)),
    planejar_semestres(Necessarias, Historico, MaxCreditos, MaxSemestres, Trilha).

% Une as obrigatórias pendentes aos seus pré-requisitos ainda não concluídos.
% Eletivas entram apenas quando necessárias para essas dependências.
disciplinas_necessarias(Pendentes, Historico, Necessarias) :-
    findall(R, (member(D, Pendentes), prerequisito_transitivo(D, R), \+ memberchk(R, Historico)), Requisitos),
    append(Pendentes, Requisitos, Todas), sort(Todas, Necessarias).

% Sem pendências, a trilha restante é vazia, inclusive para aluno já concluído.
planejar_semestres([], _, _, _, []).
% Poda ramos cuja capacidade total de créditos ou quantidade de semestres é insuficiente.
% Elegíveis usam o histórico anterior ao semestre; a seleção deve ser não vazia.
% Cada passo remove disciplinas e consome um semestre, inclusive com zero crédito.
planejar_semestres([Pendente|Pendentes], Historico, MaxCreditos, Restantes, [Semestre|Trilha]) :-
    Restantes > 0, Necessarias = [Pendente|Pendentes],
    creditos_disciplinas(Necessarias, Total), Total =< MaxCreditos * Restantes,
    forall(member(D, Necessarias), (profundidade_pendente(D, Historico, Profundidade), Profundidade =< Restantes)),
    findall(D, (member(D, Necessarias), requisitos_no_historico(D, Historico)), Elegiveis),
    ordenar_elegiveis(Elegiveis, Ordenadas), selecionar_semestre(Ordenadas, MaxCreditos, Selecionadas),
    Selecionadas = [_|_], sort(Selecionadas, Semestre),
    subtract(Necessarias, Semestre, NovasPendentes), append(Semestre, Historico, NovoHistorico),
    Proximos is Restantes - 1, planejar_semestres(NovasPendentes, NovoHistorico, MaxCreditos, Proximos, Trilha).

% Usa o histórico simulado; aprovações do semestre atual ainda não estão nele.
requisitos_no_historico(Disciplina, Historico) :-
    forall(prerequisito(Disciplina, R), memberchk(R, Historico)).

% Em uma base sem ciclos, calcula a maior cadeia ainda pendente até a disciplina.
% Uma cadeia de K disciplinas não concluídas exige pelo menos K semestres.
profundidade_pendente(Disciplina, Historico, Profundidade) :-
    findall(P, (prerequisito(Disciplina, R), \+ memberchk(R, Historico), profundidade_pendente(R, Historico, P)), Ps),
    max_list([0|Ps], Maior), Profundidade is Maior + 1.

% Prioriza períodos sugeridos anteriores e, dentro deles, créditos maiores.
% A ordenação muda a primeira resposta, mas preserva alternativas no backtracking.
ordenar_elegiveis(Disciplinas, Ordenadas) :-
    findall((Semestre-Chave)-D, (member(D, Disciplinas), disciplina(D, _, C, Semestre), Chave is -C), Pares),
    keysort(Pares, Classificados), valores_pares(Classificados, Ordenadas).

% Extrai as disciplinas dos pares já ordenados, preservando a ordem das chaves.
valores_pares([], []).
valores_pares([_-D|Pares], [D|Disciplinas]) :- valores_pares(Pares, Disciplinas).

% Enumera subconjuntos: primeiro tenta incluir a disciplina, depois tenta omiti-la.
% Disponiveis é o saldo de créditos; o chamador descarta a seleção vazia.
selecionar_semestre([], _, []).
selecionar_semestre([D|Disciplinas], Disponiveis, [D|Selecionadas]) :-
    disciplina(D, _, Creditos, _), Creditos =< Disponiveis, Restantes is Disponiveis - Creditos,
    selecionar_semestre(Disciplinas, Restantes, Selecionadas).
selecionar_semestre([_|Disciplinas], Disponiveis, Selecionadas) :-
    selecionar_semestre(Disciplinas, Disponiveis, Selecionadas).

% Coleta um único lote de até Quantidade trilhas com findnsols/4 e once/1.
% Retorna [] se não houver solução; aluno e parâmetros inválidos falham.
trilhas_limitadas(Aluno, MaxCreditos, Quantidade, Trilhas) :-
    aluno(Aluno, _, regular), integer(MaxCreditos), MaxCreditos > 0, integer(Quantidade), Quantidade > 0,
    once(findnsols(Quantidade, Trilha, trilha_valida(Aluno, MaxCreditos, Trilha), Trilhas)).
