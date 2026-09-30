
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


% pode_cursar(Aluno, Disciplina)
% O aluno pode cursar a disciplina se:
%   1. ela existe na grade curricular, e
%   2. não há registro de que o aluno já a cursou (negação por falha).


pode_cursar(Aluno, Disciplina) :-
    disciplina(Disciplina, _, _, _),   % a disciplina está na grade
    \+ cursou(Aluno, Disciplina).      % e o aluno ainda não cursou



