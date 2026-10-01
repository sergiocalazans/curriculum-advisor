% Bateria isolada: acrescenta uma referência a uma disciplina não cadastrada.
% Execute em processo separado, pois esse fato torna a base propositalmente inválida.
:- use_module(library(plunit)).
:- ensure_loaded('../src/main.pl').
:- multifile prerequisito/2.

% banco_dados existe, mas o segundo argumento não tem fato em disciplina/4.
prerequisito(banco_dados, disciplina_inexistente_teste).

% A referência não pode ser ignorada: consistência, elegibilidade e trilha falham.
:- begin_tests(base_invalida).
test(rejeita_referencia_inexistente, [fail]) :- base_consistente.
test(nao_ignora_requisito_inexistente, [fail]) :- prerequisitos_ok(diego, banco_dados).
test(nao_libera_disciplina_inconsistente, [fail]) :- pode_cursar(diego, banco_dados).
test(nao_gera_trilha_inconsistente, [fail]) :- trilha_valida(diego, 28, _).
:- end_tests(base_invalida).
