% Fixture isolada: obrigatoria pendente depende de uma eletiva.
:- use_module(library(plunit)).
:- ensure_loaded('../src/main.pl').
:- multifile disciplina/4, prerequisito/2, aluno/3, cursou/2.

disciplina(eletiva_dependencia_teste, eletiva, 2, 1).
disciplina(obrigatoria_dependencia_teste, obrigatoria, 2, 2).
prerequisito(obrigatoria_dependencia_teste, eletiva_dependencia_teste).
aluno(eletiva_teste, 8, regular).

cursou(eletiva_teste, algoritmos_programacao).
cursou(eletiva_teste, banco_dados).
cursou(eletiva_teste, fundamentos_eletricidade_optica).
cursou(eletiva_teste, introducao_computacao).
cursou(eletiva_teste, introducao_calculo).
cursou(eletiva_teste, leitura_producao_textos_academicos).
cursou(eletiva_teste, sistemas_multimidia).
cursou(eletiva_teste, calculo_I).
cursou(eletiva_teste, cultura_religiosa).
cursou(eletiva_teste, fundamentos_fisica_computacao).
cursou(eletiva_teste, logica_matematica).
cursou(eletiva_teste, metodologia_cientifica).
cursou(eletiva_teste, programacao_imperativa).
cursou(eletiva_teste, sistemas_digitais).
cursou(eletiva_teste, arquitetura_organizacao_computadores).
cursou(eletiva_teste, estruturas_dados).
cursou(eletiva_teste, filosofia).
cursou(eletiva_teste, geometria_analitica).
cursou(eletiva_teste, matematica_computacional).
cursou(eletiva_teste, matematica_discreta).
cursou(eletiva_teste, programacao_orientada_objetos).
cursou(eletiva_teste, algebra_linear).
cursou(eletiva_teste, arquitetura_banco_dados).
cursou(eletiva_teste, computacao_sociedade).
cursou(eletiva_teste, etica).
cursou(eletiva_teste, modelagem_sistemas_computacionais).
cursou(eletiva_teste, programacao_logica).
cursou(eletiva_teste, teoria_grafos).
cursou(eletiva_teste, topicos_avancados_arquitetura_computadores).
cursou(eletiva_teste, engenharia_software_I).
cursou(eletiva_teste, estatistica).
cursou(eletiva_teste, inteligencia_artificial).
cursou(eletiva_teste, programacao_funcinal).
cursou(eletiva_teste, redes_computadores_I).
cursou(eletiva_teste, sistemas_operacionais).
cursou(eletiva_teste, direito_legislacao).
cursou(eletiva_teste, engenharia_software_II).
cursou(eletiva_teste, inteligencia_computacional).
cursou(eletiva_teste, redes_computadores_II).
cursou(eletiva_teste, processamento_imagens).
cursou(eletiva_teste, seminarios_informatica).
cursou(eletiva_teste, sistemas_concorrentes).
cursou(eletiva_teste, avaliacao_desempenho_sistemas).
cursou(eletiva_teste, complexidade_algoritmos).
cursou(eletiva_teste, interacao_humano_computador).
cursou(eletiva_teste, linguagens_formais_compiladores).
cursou(eletiva_teste, projeto_comunitario).
cursou(eletiva_teste, projeto_final_I).
cursou(eletiva_teste, sistemas_distribuidos).
cursou(eletiva_teste, atividades_complementares_I).
cursou(eletiva_teste, arquitetura_sistemas_distribuidos).
cursou(eletiva_teste, computacao_grafica).
cursou(eletiva_teste, economia_administracao).
cursou(eletiva_teste, empreendedorismo_inovacao_computacao).
cursou(eletiva_teste, gestao_projetos_tecnologia_informacao).
cursou(eletiva_teste, projeto_final_II).
cursou(eletiva_teste, seguranca_auditoria_sistemas).
cursou(eletiva_teste, atividades_complementares_II).
cursou(eletiva_teste, leitura_escrita_textos_tecnicos_cientificos).

:- begin_tests(eletiva).
test(inclui_eletiva_necessaria, true(T == [[eletiva_dependencia_teste],[obrigatoria_dependencia_teste]])) :-
    once(trilha_valida(eletiva_teste, 4, T)).
test(prerequisito_no_semestre_anterior, [fail]) :-
    trilha_valida(eletiva_teste, 4, [[eletiva_dependencia_teste,obrigatoria_dependencia_teste]]).
test(sem_trilha_quando_limite_insuficiente, [fail]) :- trilha_valida(eletiva_teste, 4, 1, _).
test(formatura_exige_obrigatoria, [fail]) :- trilha_valida(eletiva_teste, 4, [[eletiva_dependencia_teste]]).
:- end_tests(eletiva).
