% Fixtures estaticas: executar esta bateria em processo separado.
:- use_module(library(plunit)).
:- ensure_loaded('../src/main.pl').
:- multifile aluno/3, cursou/2.

aluno(concluinte_teste, 8, regular).
aluno(formado_teste, 8, regular).
cursou(formado_teste, algoritmos_programacao).
cursou(formado_teste, banco_dados).
cursou(formado_teste, fundamentos_eletricidade_optica).
cursou(formado_teste, introducao_computacao).
cursou(formado_teste, introducao_calculo).
cursou(formado_teste, leitura_producao_textos_academicos).
cursou(formado_teste, sistemas_multimidia).
cursou(formado_teste, calculo_I).
cursou(formado_teste, cultura_religiosa).
cursou(formado_teste, fundamentos_fisica_computacao).
cursou(formado_teste, logica_matematica).
cursou(formado_teste, metodologia_cientifica).
cursou(formado_teste, programacao_imperativa).
cursou(formado_teste, sistemas_digitais).
cursou(formado_teste, arquitetura_organizacao_computadores).
cursou(formado_teste, estruturas_dados).
cursou(formado_teste, filosofia).
cursou(formado_teste, geometria_analitica).
cursou(formado_teste, matematica_computacional).
cursou(formado_teste, matematica_discreta).
cursou(formado_teste, programacao_orientada_objetos).
cursou(formado_teste, algebra_linear).
cursou(formado_teste, arquitetura_banco_dados).
cursou(formado_teste, computacao_sociedade).
cursou(formado_teste, etica).
cursou(formado_teste, modelagem_sistemas_computacionais).
cursou(formado_teste, programacao_logica).
cursou(formado_teste, teoria_grafos).
cursou(formado_teste, topicos_avancados_arquitetura_computadores).
cursou(formado_teste, engenharia_software_I).
cursou(formado_teste, estatistica).
cursou(formado_teste, inteligencia_artificial).
cursou(formado_teste, programacao_funcinal).
cursou(formado_teste, redes_computadores_I).
cursou(formado_teste, sistemas_operacionais).
cursou(formado_teste, direito_legislacao).
cursou(formado_teste, engenharia_software_II).
cursou(formado_teste, inteligencia_computacional).
cursou(formado_teste, redes_computadores_II).
cursou(formado_teste, processamento_imagens).
cursou(formado_teste, seminarios_informatica).
cursou(formado_teste, sistemas_concorrentes).
cursou(formado_teste, avaliacao_desempenho_sistemas).
cursou(formado_teste, complexidade_algoritmos).
cursou(formado_teste, interacao_humano_computador).
cursou(formado_teste, linguagens_formais_compiladores).
cursou(formado_teste, projeto_comunitario).
cursou(formado_teste, projeto_final_I).
cursou(formado_teste, sistemas_distribuidos).
cursou(formado_teste, atividades_complementares_I).
cursou(formado_teste, arquitetura_sistemas_distribuidos).
cursou(formado_teste, computacao_grafica).
cursou(formado_teste, economia_administracao).
cursou(formado_teste, empreendedorismo_inovacao_computacao).
cursou(formado_teste, gestao_projetos_tecnologia_informacao).
cursou(formado_teste, projeto_final_II).
cursou(formado_teste, seguranca_auditoria_sistemas).
cursou(formado_teste, atividades_complementares_II).
cursou(formado_teste, leitura_escrita_textos_tecnicos_cientificos).

cursou(concluinte_teste, algoritmos_programacao).
cursou(concluinte_teste, banco_dados).
cursou(concluinte_teste, fundamentos_eletricidade_optica).
cursou(concluinte_teste, introducao_computacao).
cursou(concluinte_teste, introducao_calculo).
cursou(concluinte_teste, leitura_producao_textos_academicos).
cursou(concluinte_teste, sistemas_multimidia).
cursou(concluinte_teste, calculo_I).
cursou(concluinte_teste, cultura_religiosa).
cursou(concluinte_teste, fundamentos_fisica_computacao).
cursou(concluinte_teste, logica_matematica).
cursou(concluinte_teste, metodologia_cientifica).
cursou(concluinte_teste, programacao_imperativa).
cursou(concluinte_teste, sistemas_digitais).
cursou(concluinte_teste, arquitetura_organizacao_computadores).
cursou(concluinte_teste, estruturas_dados).
cursou(concluinte_teste, filosofia).
cursou(concluinte_teste, geometria_analitica).
cursou(concluinte_teste, matematica_computacional).
cursou(concluinte_teste, matematica_discreta).
cursou(concluinte_teste, programacao_orientada_objetos).
cursou(concluinte_teste, algebra_linear).
cursou(concluinte_teste, arquitetura_banco_dados).
cursou(concluinte_teste, computacao_sociedade).
cursou(concluinte_teste, etica).
cursou(concluinte_teste, modelagem_sistemas_computacionais).
cursou(concluinte_teste, programacao_logica).
cursou(concluinte_teste, teoria_grafos).
cursou(concluinte_teste, topicos_avancados_arquitetura_computadores).
cursou(concluinte_teste, engenharia_software_I).
cursou(concluinte_teste, estatistica).
cursou(concluinte_teste, inteligencia_artificial).
cursou(concluinte_teste, programacao_funcinal).
cursou(concluinte_teste, redes_computadores_I).
cursou(concluinte_teste, sistemas_operacionais).
cursou(concluinte_teste, direito_legislacao).
cursou(concluinte_teste, engenharia_software_II).
cursou(concluinte_teste, inteligencia_computacional).
cursou(concluinte_teste, redes_computadores_II).
cursou(concluinte_teste, processamento_imagens).
cursou(concluinte_teste, seminarios_informatica).
cursou(concluinte_teste, sistemas_concorrentes).
cursou(concluinte_teste, avaliacao_desempenho_sistemas).
cursou(concluinte_teste, complexidade_algoritmos).
cursou(concluinte_teste, interacao_humano_computador).
cursou(concluinte_teste, linguagens_formais_compiladores).
cursou(concluinte_teste, projeto_comunitario).
cursou(concluinte_teste, projeto_final_I).
cursou(concluinte_teste, sistemas_distribuidos).
cursou(concluinte_teste, arquitetura_sistemas_distribuidos).
cursou(concluinte_teste, computacao_grafica).
cursou(concluinte_teste, economia_administracao).
cursou(concluinte_teste, empreendedorismo_inovacao_computacao).
cursou(concluinte_teste, gestao_projetos_tecnologia_informacao).
cursou(concluinte_teste, projeto_final_II).
cursou(concluinte_teste, seguranca_auditoria_sistemas).
cursou(concluinte_teste, leitura_escrita_textos_tecnicos_cientificos).

% Aprovacao repetida: a soma deve continuar contando a disciplina uma unica vez.
cursou(formado_teste, banco_dados).

:- begin_tests(finais).
test(formado_trilha_vazia, true(T == [])) :- once(trilha_valida(formado_teste, 4, T)).
test(formado_zero_semestres, true(T == [])) :- once(trilha_valida(formado_teste, 4, 0, T)).
test(formado_pendentes_creditos_sem_duplicatas) :- disciplinas_pendentes(formado_teste, []), creditos_cursados(formado_teste, 210).
test(creditos_zero_no_semestre, true(T == [[atividades_complementares_I,atividades_complementares_II]])) :-
    once(trilha_valida(concluinte_teste, 4, T)).
test(findall_enumera_todas, true(N == 3)) :- findall(T, trilha_valida(concluinte_teste, 4, T), Ts), length(Ts, N).
test(bagof_enumera_todas, true(N == 3)) :- bagof(T, trilha_valida(concluinte_teste, 4, T), Ts), length(Ts, N).
test(sem_repeticao, true(N == 3)) :- findall(T, trilha_valida(concluinte_teste, 4, T), Ts), sort(Ts, Unicas), length(Unicas, N).
test(limite_um_semestre, true(Ts == [[[atividades_complementares_I,atividades_complementares_II]]])) :-
    findall(T, trilha_valida(concluinte_teste, 4, 1, T), Ts).
test(coleta_quantidade_maior_que_total, true(N == 3)) :- once(trilhas_limitadas(concluinte_teste, 4, 10, Ts)), length(Ts, N).
:- end_tests(finais).
