% Fixture isolada: pre-requisito aponta para uma disciplina nao cadastrada.
:- use_module(library(plunit)).
:- ensure_loaded('../src/main.pl').
:- multifile prerequisito/2.

prerequisito(banco_dados, disciplina_inexistente_teste).

:- begin_tests(base_invalida).
test(rejeita_referencia_inexistente, [fail]) :- base_consistente.
test(nao_ignora_requisito_inexistente, [fail]) :- prerequisitos_ok(diego, banco_dados).
test(nao_libera_disciplina_inconsistente, [fail]) :- pode_cursar(diego, banco_dados).
test(nao_gera_trilha_inconsistente, [fail]) :- trilha_valida(diego, 28, _).
:- end_tests(base_invalida).
