% Executar em processo separado: esta fixture acrescenta um ciclo estatico de proposito.
:- use_module(library(plunit)).
:- use_module(library(time)).
:- ensure_loaded('../src/main.pl').
:- multifile prerequisito/2.

prerequisito(algoritmos_programacao, programacao_imperativa).

:- begin_tests(ciclo).
test(detecta_origem) :- existe_ciclo(algoritmos_programacao).
test(detecta_outro_vertice) :- existe_ciclo(programacao_imperativa).
test(transitivo_nao_trava) :- call_with_time_limit(2, findall(A, prerequisito_transitivo(algoritmos_programacao, A), _)).
test(base_rejeitada, [fail]) :- base_consistente.
test(busca_rejeita_ciclo, [fail]) :- call_with_time_limit(2, trilha_valida(diego, 28, _)).
:- end_tests(ciclo).
