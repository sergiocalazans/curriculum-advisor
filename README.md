# Curriculum Advisor

Sistema de trilha de disciplinas em **SWI-Prolog**, para o PjBL 1 de Programação Lógica e Funcional. Representa uma grade curricular, verifica elegibilidade e gera planos de conclusão das disciplinas obrigatórias por recursão e backtracking.

## Requisitos

- SWI-Prolog instalado, com o comando `swipl` disponível no terminal.
- Validado em SWI-Prolog **10.0.2**, em Windows.
- Não exige instalação de bibliotecas externas, pacotes Prolog adicionais, Python ou serviços.
- Os arquivos devem permanecer juntos e em UTF-8.

São usadas apenas funcionalidades e bibliotecas que acompanham o SWI-Prolog: `lists` no sistema; `plunit`, `time`, `process` e `filesex` nos testes e no executor.

## Estrutura

```text
curriculum-advisor/
  src/
    curriculum.pl             Base de fatos
    elegibilidade.pl          Regras de elegibilidade e soma de créditos
    trilhas.pl                Fecho transitivo, ciclos e planejamento
    main.pl                   Carregamento e demo/0
  tests/
    consultas_teste.pl        Testes das três camadas e validador independente
    teste_ciclo.pl            Base com ciclo inserido de propósito
    teste_finais.pl           Formado, créditos zero e findall/bagof completos
    teste_eletiva.pl          Eletiva necessária como pré-requisito
    teste_base_invalida.pl    Referência a disciplina inexistente
    executar_testes.pl        Executor das cinco baterias em processos separados
  docs/
    decisoes.md               Modelagem, algoritmo, agregação e limitações
  LICENSE
  README.md
```

## Executar a demonstração

Abra o terminal na pasta `curriculum-advisor` extraída do ZIP:

```bash
# Executa demo/0 e encerra o interpretador ao terminar.
swipl -q -s src/main.pl -g demo -t halt
```

O comando mostra a base do primeiro semestre, consultas de Carla, pré-requisitos transitivos, ausência de ciclos, uma trilha completa de Diego e três trilhas distintas para Ana.

Para usar o interpretador interativo:

```bash
# Carrega o sistema e mantém o interpretador aberto para consultas.
swipl -q -s src/main.pl
```

Também é possível abrir o SWI-Prolog, selecionar **File > Consult** e escolher `src/main.pl`. Depois, execute as consultas abaixo, com ponto final. As diretivas de carregamento resolvem os caminhos em relação aos arquivos; não dependem de executar o interpretador dentro de `src`.

## Consultas de exemplo

```prolog
% Camada 1: disciplinas sugeridas para o primeiro semestre.
findall(D, disciplina(D, _, _, 1), Disciplinas).

% Camada 2: elegibilidade, pendências e créditos.
prerequisitos_ok(ana, linguagens_formais_compiladores). % true: ambos os requisitos concluídos.
pode_cursar(carla, projeto_final_II).         % false: pré-requisito pendente.
pode_cursar(ana, algoritmos_programacao).    % false: já cursada.
disciplinas_liberadas(carla, Lista).         % Elegíveis, incluindo eletivas liberadas.
disciplinas_pendentes(ana, Lista).           % Apenas obrigatórias não concluídas.
creditos_cursados(ana, Total).               % Total = 176.
creditos_cursados(bruno, Total).             % Total = 140.
creditos_cursados(carla, Total).             % Total = 96.
creditos_cursados(diego, Total).             % Total = 0.
disciplinas_liberadas(uriel, Lista).         % Lista = []: aluno trancado.
disciplinas_liberadas(inexistente, Lista).   % false, sem exceção.

% Camada 3: cadeia com seis arestas e detecção de ciclos.
prerequisito_transitivo(arquitetura_sistemas_distribuidos, fundamentos_eletricidade_optica).
existe_ciclo(_).                            % false na base normal.
base_consistente.                          % true.

% Primeira trilha válida; não há garantia de ser a mais curta.
once(trilha_valida(diego, 28, Trilha)).

% Até três soluções, coletadas sem enumerar todo o espaço.
trilhas_limitadas(ana, 28, 3, Trilhas).

% Versão adicional com limite próprio, sempre até 12 semestres.
once(trilha_valida(carla, 28, 8, Trilha)).
trilha_valida(diego, 28, 13, Trilha).        % false: ultrapassa o teto.

demo.                                     % Demonstra as três camadas.
halt.                                     % Encerra a sessão interativa.
```

`trilha_valida/3` deixa alternativas disponíveis: após obter uma solução no interpretador, pressione `;` para solicitar a seguinte. Use `once/1` quando quiser apenas a primeira. O resultado é uma lista de semestres, sendo cada semestre uma lista de disciplinas.

O limite de créditos é um inteiro positivo. A disciplina só entra no semestre se todos os pré-requisitos estiverem no histórico **antes** dele; cursar duas disciplinas no mesmo semestre não satisfaz a dependência entre elas.

O semestre sugerido orienta a ordem da busca; não representa uma restrição obrigatória. A trilha termina quando todas as obrigatórias pendentes e seus pré-requisitos necessários foram concluídos. Eletivas sem essa função ficam fora do plano, conforme o escopo adotado.

## Executar todos os testes

```bash
# Executa as cinco baterias em processos separados.
swipl -q -s tests/executar_testes.pl
```

O executor abre um processo SWI-Prolog por bateria. Ao final, deve imprimir:

```text
Todas as baterias passaram.
```

São **88 testes em cinco baterias**. Qualquer falha faz o executor encerrar com código diferente de zero.

Para executar cada bateria individualmente:

```bash
# Cada comando carrega uma bateria, executa os testes e encerra a sessão.
swipl -q -s tests/consultas_teste.pl -g run_tests -t halt
swipl -q -s tests/teste_ciclo.pl -g run_tests -t halt
swipl -q -s tests/teste_finais.pl -g run_tests -t halt
swipl -q -s tests/teste_eletiva.pl -g run_tests -t halt
swipl -q -s tests/teste_base_invalida.pl -g run_tests -t halt
```

**Não consulte todas as fixtures no mesmo interpretador.** `teste_ciclo.pl` acrescenta propositalmente um ciclo, e `teste_base_invalida.pl` acrescenta uma referência inválida. Isso é material de teste, não parte do currículo normal. O executor já mantém as baterias isoladas.

## Enumerar todas as soluções com findall/3 e bagof/3

O enunciado exige demonstrar múltiplas trilhas. A fixture `teste_finais.pl` contém um aluno com apenas duas obrigatórias de zero crédito pendentes, permitindo enumerar o conjunto completo sem explosão combinatória.

Inicie uma sessão separada:

```bash
# Carrega a bateria dos alunos formado e concluinte em uma sessão separada.
swipl -q -s tests/teste_finais.pl
```

```prolog
% Nesse cenário há exatamente três trilhas, viáveis para enumeração completa.
findall(T, trilha_valida(concluinte_teste, 4, T), Trilhas).
bagof(T, trilha_valida(concluinte_teste, 4, T), Trilhas).
```

Ambas retornam exatamente estas três possibilidades, cuja ordem pode ser lida diretamente da execução:

```prolog
[[[atividades_complementares_I, atividades_complementares_II]],
 [[atividades_complementares_I], [atividades_complementares_II]],
 [[atividades_complementares_II], [atividades_complementares_I]]]
```

Para os alunos da base completa, prefira `trilhas_limitadas/4`. Embora haja limite de semestres, o número de trilhas pode ser grande.

## Entrega e apresentação

O código atende às três camadas e possui demonstração, testes de ciclo separados, tratamento de consultas inexistentes e documentação de decisões.

Antes de entregar, execute os dois comandos principais no computador do grupo: demonstração e testes. A validação desta revisão foi feita em Windows com SWI-Prolog 10.0.2.

Todos os integrantes devem conseguir explicar o código. O modelo curricular parte da base enviada pelo grupo; as relações são didáticas e não representam uma validação oficial da matriz ou das normas de matrícula da instituição.
