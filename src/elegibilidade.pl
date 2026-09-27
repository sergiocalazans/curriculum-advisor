
% Carrega o arquivo indicado, evitando carregamentos repetidos desnecessários.
:- ensure_loaded('curriculum.pl').

% Verifica se o aluno pode cursar a disciplina, ou seja, se ele já cursou todas as disciplinas obrigatórias que são pré-requisitos da disciplina em questão.
disciplinas_liberadas(Aluno, Lista) :-
    findall(
        Disciplina,
        pode_cursar(Aluno, Disciplina),
        Disciplinas
    ),
    sort(Disciplinas, Lista).


% Verifica se o aluno já cursou todas as disciplinas obrigatórias que são pré-requisitos da disciplina em questão.
disciplinas_pendentes(Aluno, Lista) :-
    findall(
        Disciplina,
        (
            disciplina(Disciplina, obrigatoria, _, _),
            \+ cursou(Aluno, Disciplina)
        ),
        Disciplinas
    ),
    sort(Disciplinas, Lista).