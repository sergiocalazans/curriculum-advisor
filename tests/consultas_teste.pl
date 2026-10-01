:- use_module(library(plunit)).
:- use_module(library(time)).
:- ensure_loaded('../src/main.pl').

:- begin_tests(curriculum).

test(minimo_disciplinas) :- findall(D, disciplina(D, _, _, _), Ds), sort(Ds, Unicos), length(Unicos, N), N >= 20.
test(minimo_semestres) :- setof(S, D^T^C^disciplina(D, T, C, S), Ss), length(Ss, N), N >= 6.
test(minimo_eletivas) :- setof(D, C^S^disciplina(D, eletiva, C, S), Ds), length(Ds, N), N >= 3.
test(tres_perfis) :- situacao_aluno(ana, adiantado), situacao_aluno(bruno, no_ritmo), situacao_aluno(carla, atrasado).
test(aluno_sem_historico) :- historico_aluno(diego, []), creditos_cursados(diego, 0).
test(base_consistente) :- base_consistente.
test(nomes_unicos) :- findall(D, disciplina(D, _, _, _), Ds), sort(Ds, Unicos), same_length(Ds, Unicos).
test(semestre_um, true(Ds == [algoritmos_programacao,banco_dados,fundamentos_eletricidade_optica,introducao_computacao,introducao_calculo,leitura_producao_textos_academicos,sistemas_multimidia])) :-
    findall(D, disciplina(D, _, _, 1), Ds).
test(historicos_coerentes) :- forall(cursou(A, D), prerequisitos_ok(A, D)).
test(multiplos_prerequisitos) :- findall(R, prerequisito(sistemas_distribuidos, R), Rs), length(Rs, 2).

:- end_tests(curriculum).
:- begin_tests(elegibilidade).

test(liberadas_diferentes) :- disciplinas_liberadas(ana, A), disciplinas_liberadas(bruno, B), disciplinas_liberadas(carla, C), A \== B, B \== C.
test(pendentes_diferentes) :- disciplinas_pendentes(ana, A), disciplinas_pendentes(bruno, B), disciplinas_pendentes(carla, C), A \== B, B \== C.
test(quantidades_pendentes, true([A,B,C] == [14,24,34])) :-
    disciplinas_pendentes(ana, As), length(As, A), disciplinas_pendentes(bruno, Bs), length(Bs, B), disciplinas_pendentes(carla, Cs), length(Cs, C).
test(liberadas_respeitam_prerequisitos) :-
    forall(aluno(A, _, regular), (disciplinas_liberadas(A, Ds), forall(member(D, Ds), prerequisitos_ok(A, D)))).
test(liberadas_nao_cursadas) :- disciplinas_liberadas(bruno, Ds), forall(member(D, Ds), \+ cursou(bruno, D)).
test(pendente_nao_e_elegivel) :- disciplinas_pendentes(carla, Ds), memberchk(projeto_final_II, Ds), \+ pode_cursar(carla, projeto_final_II).
test(nega_cursada, [fail]) :- pode_cursar(ana, algoritmos_programacao).
test(historico_muda_elegibilidade) :- pode_cursar(diego, algoritmos_programacao), \+ pode_cursar(ana, algoritmos_programacao).
test(bloqueia_prerequisito, [fail]) :- pode_cursar(carla, projeto_final_II).
test(multiplos_prerequisitos_satisfeitos) :- once(pode_cursar(ana, linguagens_formais_compiladores)).
test(multiplos_prerequisitos_incompletos, [fail]) :- pode_cursar(diego, linguagens_formais_compiladores).
test(sem_prerequisito) :- prerequisitos_ok(diego, banco_dados), pode_cursar(diego, banco_dados).
test(creditos_ana, true(C == 176)) :- creditos_cursados(ana, C).
test(creditos_bruno, true(C == 140)) :- creditos_cursados(bruno, C).
test(creditos_carla, true(C == 96)) :- creditos_cursados(carla, C).
test(creditos_zero, true(C == 0)) :- creditos_cursados(uriel, C).
test(trancado_sem_liberadas, true(Ds == [])) :- disciplinas_liberadas(uriel, Ds).
test(trancado_com_pendentes) :- disciplinas_pendentes(uriel, Ds), Ds = [_|_].
test(resultados_ordenados) :- disciplinas_liberadas(carla, A), disciplinas_pendentes(carla, B), sort(A, A), sort(B, B).
test(aluno_inexistente_liberadas, [fail]) :- disciplinas_liberadas(inexistente, _).
test(aluno_inexistente_pendentes, [fail]) :- disciplinas_pendentes(inexistente, _).
test(aluno_inexistente_creditos, [fail]) :- creditos_cursados(inexistente, _).
test(aluno_inexistente_requisitos, [fail]) :- prerequisitos_ok(inexistente, banco_dados).
test(disciplina_inexistente, [fail]) :- pode_cursar(ana, inexistente).
test(disciplina_inexistente_requisitos, [fail]) :- prerequisitos_ok(ana, inexistente).
test(enumera_alunos) :- setof(A, pode_cursar(A, banco_dados), [diego]).
test(enumera_disciplinas) :- findall(D, pode_cursar(carla, D), Ds), Ds = [_|_], forall(member(D, Ds), atom(D)).
test(situacao_incorreta, [fail]) :- situacao_aluno(ana, no_ritmo).
test(situacao_inexistente, [fail]) :- situacao_aluno(inexistente, _).

:- end_tests(elegibilidade).

% Validador independente da busca: reconstroi o historico semestre por semestre.
verificar_trilha(Aluno, MaxCreditos, Trilha) :-
    length(Trilha, N), N =< 12, historico_aluno(Aluno, Historico),
    verificar_semestres(Trilha, Historico, MaxCreditos, Final),
    disciplinas_pendentes(Aluno, Pendentes), forall(member(D, Pendentes), memberchk(D, Final)).

verificar_semestres([], Historico, _, Historico).
verificar_semestres([Semestre|Trilha], Historico, MaxCreditos, Final) :-
    Semestre = [_|_], sort(Semestre, Semestre),
    findall(C, (member(D, Semestre), disciplina(D, _, C, _)), Cs), sum_list(Cs, Total), Total =< MaxCreditos,
    forall(member(D, Semestre), (\+ memberchk(D, Historico), forall(prerequisito(D, R), memberchk(R, Historico)))),
    append(Semestre, Historico, NovoHistorico), verificar_semestres(Trilha, NovoHistorico, MaxCreditos, Final).

:- begin_tests(trilhas).

test(direto) :- prerequisito_transitivo(programacao_imperativa, algoritmos_programacao).
test(profundidade_seis) :- prerequisito_transitivo(arquitetura_sistemas_distribuidos, fundamentos_eletricidade_optica).
test(profundidade_quatro) :- prerequisito_transitivo(projeto_final_II, modelagem_sistemas_computacionais).
test(sem_ciclo, [fail]) :- existe_ciclo(_).
test(transitivo_inexistente, [fail]) :- prerequisito_transitivo(inexistente, _).
test(ancestral_inexistente, [fail]) :- prerequisito_transitivo(_, inexistente).
test(transitivo_enumera_sem_duplicatas) :-
    findall(A, prerequisito_transitivo(arquitetura_sistemas_distribuidos, A), As), sort(As, Unicos), same_length(As, Unicos), length(As, 8).
test(trilha_completa_do_zero) :- once(trilha_valida(diego, 28, T)), verificar_trilha(diego, 28, T).
test(trilha_ana) :- once(trilha_valida(ana, 28, T)), verificar_trilha(ana, 28, T).
test(trilha_bruno) :- once(trilha_valida(bruno, 28, T)), verificar_trilha(bruno, 28, T).
test(trilha_carla) :- once(trilha_valida(carla, 28, T)), verificar_trilha(carla, 28, T).
test(multiplas_trilhas) :-
    once(trilhas_limitadas(ana, 28, 3, Ts)), length(Ts, 3), sort(Ts, Unicas), length(Unicas, 3), forall(member(T, Ts), verificar_trilha(ana, 28, T)).
test(nao_muda_historico) :-
    findall(A-D, cursou(A, D), Antes), once(trilhas_limitadas(ana, 28, 3, _)), findall(A-D, cursou(A, D), Depois), Antes == Depois.
test(sem_eletivas_desnecessarias) :-
    once(trilha_valida(diego, 28, T)), append(T, Ds), forall(member(D, Ds), disciplina(D, obrigatoria, _, _)).
test(limite_semestres_impossivel, [fail]) :- trilha_valida(diego, 28, 1, _).
test(cadeia_maior_que_limite, [fail]) :- call_with_time_limit(2, trilha_valida(diego, 1000, 6, _)).
test(teto_doze, [fail]) :- trilha_valida(diego, 28, 13, _).
test(zero_semestres_pendente, [fail]) :- trilha_valida(ana, 28, 0, _).
test(credito_insuficiente, [fail]) :- trilha_valida(diego, 2, _).
test(credito_zero, [fail]) :- trilha_valida(ana, 0, _).
test(credito_negativo, [fail]) :- trilha_valida(ana, -1, _).
test(credito_texto, [fail]) :- trilha_valida(ana, abc, _).
test(credito_livre, [fail]) :- trilha_valida(ana, _, _).
test(limite_texto, [fail]) :- trilha_valida(ana, 28, abc, _).
test(aluno_inexistente, [fail]) :- trilha_valida(inexistente, 28, _).
test(trancado, [fail]) :- trilha_valida(uriel, 28, _).
test(quantidade_invalida, [fail]) :- trilhas_limitadas(ana, 28, 0, _).

:- end_tests(trilhas).
