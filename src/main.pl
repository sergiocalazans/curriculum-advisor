:- ensure_loaded('curriculum.pl').
:- ensure_loaded('elegibilidade.pl').
:- ensure_loaded('trilhas.pl').

demo :-
    writeln('=== CAMADA 1: base curricular ==='),
    findall(D, disciplina(D, _, _, 1), PrimeiroSemestre), writeln(PrimeiroSemestre),
    writeln('=== CAMADA 2: elegibilidade de Carla ==='),
    disciplinas_liberadas(carla, Liberadas), format('Liberadas: ~w~n', [Liberadas]),
    disciplinas_pendentes(carla, Pendentes), format('Pendentes: ~w~n', [Pendentes]),
    creditos_cursados(carla, Creditos), format('Creditos cursados: ~d~n', [Creditos]),
    writeln('=== CAMADA 3: fecho transitivo e trilhas ==='),
    findall(A, prerequisito_transitivo(arquitetura_sistemas_distribuidos, A), Ancestrais),
    format('Pre-requisitos diretos e indiretos: ~w~n', [Ancestrais]),
    ( existe_ciclo(_) -> writeln('ERRO: ciclo na base.'), fail ; writeln('Base sem ciclos.') ),
    once(trilha_valida(diego, 28, Trilha)), writeln('Trilha do zero ate concluir as obrigatorias (Diego):'),
    mostrar_trilha(Trilha, 1),
    trilhas_limitadas(ana, 28, 3, Trilhas), length(Trilhas, Total),
    format('Amostra de ~d trilhas diferentes para Ana:~n', [Total]), writeln(Trilhas).

mostrar_trilha([], _).
mostrar_trilha([Disciplinas|Trilha], Numero) :-
    creditos_disciplinas(Disciplinas, Creditos), format('Semestre ~d (~d creditos): ~w~n', [Numero, Creditos, Disciplinas]),
    Proximo is Numero + 1, mostrar_trilha(Trilha, Proximo).
