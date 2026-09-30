% Carrega o arquivo indicado, evitando carregamentos repetidos desnecessários.
:- ensure_loaded('curriculum.pl').


% ==========================================
% PREDICADOS PRESENTES NAS ESPECIFICAÇÕES
% ==========================================

% avalia se o aluno cumpre os pré-requisitos diretos de uma disciplina.
prerequisitos_ok(Aluno, Disciplina) :-
    aluno(Aluno, _, _),                 % verifica se o aluno existe
    disciplina(Disciplina, _, _, _),    % verifica se a disciplina existe no curriculo
    forall(
        (
            prerequisito(Disciplina, PreRequisito),
            disciplina(PreRequisito, _, _, _)
        ),
        cursou(Aluno, PreRequisito)
    ).

% avalia elegibilidade de um aluno para determinada disciplina:
pode_cursar(Aluno, Disciplina) :-
    aluno(Aluno, _, regular),               % verifica se o aluno existe e esta regular
    disciplina(Disciplina, _, _, _),        % verifica se a disciplina existe no curriculo
    prerequisitos_ok(Aluno, Disciplina),    % verifica se o aluno concluiu os pré-requisitos obrigatórios da disciplina
    \+ cursou(Aluno, Disciplina).           % verifica se o aluno ainda não cursou a disciplina
      

% Lista, em ordem e sem repetição, todas as disciplinas que o aluno pode cursar agora.
disciplinas_liberadas(Aluno, Lista) :-
    aluno(Aluno, _, _),
    findall(
        Disciplina,
        pode_cursar(Aluno, Disciplina),
        Disciplinas
    ),
    sort(Disciplinas, Lista).


% Verifica todas as disciplinas obrigatórias não cursadas, independente da elegibilidade do aluno.
disciplinas_pendentes(Aluno, Lista) :-
    aluno(Aluno, _, _),
    findall(
        Disciplina,
        (
            disciplina(Disciplina, obrigatoria, _, _),
            \+ cursou(Aluno, Disciplina)
        ),
        Disciplinas
    ),
    sort(Disciplinas, Lista).



% Soma os créditos das disciplinas cursadas por um aluno.
creditos_cursados(Aluno, Total) :-
    aluno(Aluno, _, _),
    findall(
        Credito,
        (
            cursou(Aluno, Disciplina),
            disciplina(Disciplina, _, Credito, _)
        ),
        ListaCreditos
    ),
    sum_list(ListaCreditos, Total).





% Classifica o ritmo do aluno. sem adiantamento, no ritmo ou atrasado.
situacao_aluno(Aluno, Situacao) :-
    aluno(Aluno, Semestre, regular),
    (   \+ em_dia(Aluno, Semestre)
    ->  Situacao = atrasado
    ;   adiantou_disciplina(Aluno, Semestre)
    ->  Situacao = adiantado
    ;   Situacao = no_ritmo
    ).



% Verdadeiro se o aluno cursou todas as obrigatórias sugeridas para semestres
% anteriores a Semestre. Eletivas ficam de fora porque o aluno escolhe quando cursá-las.
em_dia(Aluno, Semestre) :-
    aluno(Aluno, Semestre, regular),
    forall(
        (
            disciplina(Disciplina, obrigatoria, _, Sugerido),
            Sugerido < Semestre
        ),
        cursou(Aluno, Disciplina)
    ).



% Verdadeiro se o aluno já cursou alguma disciplina (obrigatória ou eletiva)
% sugerida para Semestre ou para um semestre posterior.

adiantou_disciplina(Aluno, Semestre) :-
    aluno(Aluno, Semestre, regular),
    cursou(Aluno, Disciplina),
    disciplina(Disciplina, _, _, Sugerido),
    Sugerido >= Semestre.