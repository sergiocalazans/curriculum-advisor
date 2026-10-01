:- use_module(library(process)).
:- use_module(library(lists)).
:- use_module(library(filesex)).

% Um processo por fixture impede que fatos malformados vazem para as outras baterias.
:- initialization(main, main).

main :-
    source_file(main, Arquivo), file_directory_name(Arquivo, Diretorio),
    current_prolog_flag(executable, Executavel),
    Arquivos = ['consultas_teste.pl', 'teste_ciclo.pl', 'teste_finais.pl', 'teste_eletiva.pl', 'teste_base_invalida.pl'],
    ( forall(member(Consulta, Arquivos), executar_bateria(Executavel, Diretorio, Consulta))
    -> writeln('Todas as baterias passaram.'), halt(0)
    ; writeln('Falha na validacao. Confira a bateria indicada acima.'), halt(1) ).

executar_bateria(Executavel, Diretorio, Nome) :-
    directory_file_path(Diretorio, Nome, Caminho), format('~n=== ~w ===~n', [Nome]),
    process_create(Executavel, ['-q', '-s', Caminho, '-g', 'run_tests', '-t', 'halt'], [process(Processo)]),
    process_wait(Processo, exit(0)).
