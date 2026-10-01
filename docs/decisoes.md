# Decisões de modelagem e limitações

## 1. Base curricular e alunos

A base contém 63 disciplinas distintas, 59 obrigatórias e 4 eletivas, distribuídas em 8 semestres sugeridos. As relações de pré-requisito usam um fato `prerequisito/2` por par; uma disciplina pode exigir várias outras.

O currículo parte do material já cadastrado pelo grupo. Acrescentamos relações didáticas coerentes para exercitar dependências múltiplas e normalizamos o identificador de Programação Funcional. Não houve conferência com uma matriz curricular oficial. Em particular, semestre sugerido não implica disponibilidade da disciplina em determinado período nem equivale a uma regra de elegibilidade.

`atividades_complementares_I` e `atividades_complementares_II` representam dois componentes separados. Isso elimina a ambiguidade do identificador que aparecia duas vezes na versão original. Ambos têm zero créditos no modelo; a busca permite cursá-los e não depende de reduzir créditos para terminar.

Os fatos `aluno/3` identificam alunos mesmo quando não existe `cursou/2`. Perfis:

| Aluno | Semestre atual | Status | Perfil |
|---|---:|---|---|
| Ana | 6 | regular | Adiantada |
| Bruno | 6 | regular | No ritmo |
| Carla | 5 | regular | Atrasada |
| Uriel | 3 | trancado | Sem histórico; matrícula bloqueada |
| Diego | 1 | regular | Sem histórico; permite testar o planejamento do zero |

`cursou/2` significa disciplina concluída com aprovação. Notas, reprovações, equivalências e disciplinas em andamento não são representadas. O histórico é considerado autoritativo; não se exige que ele registre a ordem temporal das aprovações.

Os fatos continuam separados das regras. A declaração `multifile` apenas permite acrescentar fixtures estáticas em outros arquivos; não representa uma regra de domínio e não torna os predicados dinâmicos.

Os comentários dos arquivos Prolog explicam o propósito dos predicados, as premissas dos auxiliares e os cenários de teste. Blocos de fatos são comentados em conjunto. Os identificadores permanecem sem acentos, enquanto os comentários em português usam a ortografia convencional em UTF-8.

## 2. Elegibilidade e negação por falha

`prerequisitos_ok/2` primeiro enumera um aluno e uma disciplina cadastrados. Depois, `forall(prerequisito(D, R), cursou(A, R))` exige todos os pré-requisitos diretos. Uma referência a requisito inexistente não é filtrada silenciosamente: a verificação falha por não existir aprovação correspondente.

Se não houver pré-requisitos, `forall/2` é verdadeiro por vacuidade. Isso permite cursar uma disciplina inicial sem adicionar regras especiais por nome.

`pode_cursar/2` acrescenta a condição de aluno regular e `\+ cursou(A, D)`. Aluno e disciplina são instanciados por fatos antes da negação. Assim, consultas com variáveis podem enumerar pares elegíveis sem testar negação sobre variáveis livres.

A restrição de status é uma decisão adicional: aluno trancado mantém histórico e pendências consultáveis, mas não possui disciplinas liberadas nem recebe uma trilha de matrícula. Não existe bloqueio por estar adiantado ou atrasado.

`situacao_aluno/2` compara o histórico ao semestre atual: pendências anteriores indicam atraso; sem elas, uma aprovação do semestre atual ou posterior indica adiantamento. A situação é auxiliar e não interfere na elegibilidade.

## 3. findall, sort, setof, bagof e forall

- `findall/3` coleta respostas, inclusive repetidas, e retorna `[]` quando não há respostas. Não agrupa por variáveis livres do objetivo.
- `sort/2`, aplicado após `findall/3`, ordena e remove duplicatas das listas de disciplinas e do histórico.
- `setof/3` ordena e elimina duplicatas, mas falha quando não existe resposta. Também agrupa por variáveis livres não quantificadas. Os testes usam `D^T^C^...` para que a coleta de semestres não seja agrupada por disciplina, tipo ou créditos.
- `bagof/3` coleta respostas mantendo repetidas, falha se vazio e também agrupa por variáveis livres. Na fixture de conclusão, aluno e limite são constantes; só a trilha é coletada.
- `forall/2` verifica uma propriedade para todos os casos; não é usado para coletar uma lista.

Preferimos `findall` seguido de `sort` nas consultas públicas de listas porque um aluno válido deve receber `[]` quando não houver resultados. Um aluno inexistente falha antes da agregação. Esse comportamento diferencia lista vazia válida de identidade inválida.

Na soma de créditos, primeiro obtemos um histórico sem duplicatas. Depois, somamos os créditos das disciplinas por recursão. Um fato de aprovação repetido não faz a disciplina contar duas vezes. A consistência da base exige identificadores únicos de disciplina, evitando créditos ambíguos.

## 4. Fecho transitivo e ciclos

O caso base de `caminho_prerequisito/3` é uma aresta direta. O caso recursivo caminha para um pré-requisito ainda não visitado, acrescentando-o à lista `Visitados`. Como o grafo é finito e cada passo recursivo acrescenta um vértice novo, a profundidade de cada caminho é limitada.

A aresta final é verificada antes da restrição de visitados. Isso permite encontrar um caminho que volta à origem e concluir `existe_ciclo(D)` por `prerequisito_transitivo(D, D)`, sem recursão infinita.

`prerequisito_transitivo/2` enumera disciplinas e ancestrais existentes antes de usar `once/1` no caminho. O `once` seleciona uma prova por par já instanciado; não impede enumerar os outros ancestrais. Isso evita respostas duplicadas quando há mais de um caminho entre o mesmo par.

`base_consistente/0` verifica identificadores únicos, tipos, créditos não negativos, semestres positivos, alunos, referências de pré-requisito e histórico, e ausência de ciclos. O planejamento rejeita a base inconsistente antes de iniciar sua recursão. A base normal contém uma cadeia de seis arestas, por exemplo:

```prolog
% Leitura ilustrativa: cada seta aponta da disciplina para seu pré-requisito.
arquitetura_sistemas_distribuidos
  -> sistemas_distribuidos
  -> sistemas_concorrentes
  -> sistemas_operacionais
  -> arquitetura_organizacao_computadores
  -> sistemas_digitais
  -> fundamentos_eletricidade_optica
```

As setas acima descrevem dependências no texto; os fatos continuam um por par no código.

## 5. Geração de trilhas

O estado de cada chamada é composto por disciplinas necessárias ainda pendentes, histórico acumulado, limite de créditos e semestres restantes. A busca nunca usa `assert/1`, `assertz/1`, `retract/1` ou `retractall/1` para simular aprovações.

Passos:

1. Obter as obrigatórias pendentes e todos os seus pré-requisitos ainda não concluídos.
2. Rejeitar o plano se uma disciplina necessária tiver mais créditos que o limite por semestre.
3. Parar com `[]` quando não houver disciplina necessária pendente.
4. Rejeitar o ramo se os semestres restantes forem insuficientes para os créditos totais ou para a maior cadeia pendente.
5. Coletar elegíveis usando apenas o histórico anterior ao semestre.
6. Gerar um subconjunto não vazio das elegíveis, com soma de créditos dentro do limite.
7. Remover esse subconjunto das pendências, acrescentá-lo ao histórico e consumir um semestre.
8. Recorrer; no backtracking, experimentar outros subconjuntos.

`selecionar_semestre/3` tem duas alternativas: incluir a disciplina, se houver créditos disponíveis, ou não incluí-la. A ordem prioriza semestres sugeridos anteriores e, dentro deles, disciplinas com mais créditos. É uma heurística para a primeira resposta, não uma restrição: ambas as alternativas continuam disponíveis.

Semestres vazios são excluídos. Além de não contribuir para a conclusão, eles criariam muitas variações inúteis do mesmo plano. Disciplinas de zero crédito continuam sendo progresso porque são retiradas das pendências.

Os pré-requisitos não podem ser cumpridos simultaneamente com a disciplina dependente. A lista de elegíveis é calculada antes de escolher o semestre, garantindo que a dependência foi satisfeita em semestre anterior ou no histórico original. Os pré-requisitos indiretos são respeitados pela mesma regra aplicada em todos os passos.

Eletivas não são metas obrigatórias, mas entram no conjunto necessário se forem pré-requisitos de alguma obrigatória pendente. Esse cenário é validado em `teste_eletiva.pl`.

O predicado obrigatório `trilha_valida/3` usa teto de 12 semestres. A extensão `trilha_valida/4` permite um limite menor; um valor acima de 12 falha. Não há promessa de obter a trilha mais curta: a primeira solução é válida, mas não necessariamente ótima.

## 6. Uma trilha e múltiplas trilhas

`once(trilha_valida(...))` obtém apenas a primeira resposta. Chamadas diretas de `trilha_valida/3` permitem solicitar outras respostas com `;`.

`trilhas_limitadas/4` usa `findnsols/4`, fornecido pelo SWI-Prolog, para coletar até N respostas. Como esse predicado pode fornecer novos lotes no backtracking, um `once/1` interno restringe a coleta a um único lote. Se não houver plano, a lista é vazia; aluno ou parâmetros inválidos falham.

Os testes demonstram enumeração completa com `findall/3` e `bagof/3` num cenário pequeno com exatamente três trilhas. Assim, comprovam o requisito do professor sem tentar materializar todas as combinações da grade inteira.

## 7. Robustez e modos de uso

| Predicado | Entradas usuais | Comportamento de borda |
|---|---|---|
| `prerequisitos_ok/2` | Aluno e disciplina; também enumera variáveis | Identidade inexistente falha |
| `pode_cursar/2` | Aluno e/ou disciplina | Trancado, já cursada ou requisito pendente falham |
| Consultas de listas | Aluno cadastrado | Retornam lista ordenada; identidade inexistente falha |
| `creditos_cursados/2` | Aluno cadastrado | Sem histórico retorna zero |
| `prerequisito_transitivo/2` | Disciplina e/ou ancestral | Inexistente falha; ciclos não provocam loop |
| `trilha_valida/3` | Aluno, créditos inteiros positivos, trilha livre | Plano inviável ou base inconsistente falham |
| `trilha_valida/4` | Como acima; limite inteiro de 0 a 12 | Zero só permite trilha vazia de aluno já concluído |
| `trilhas_limitadas/4` | Aluno, créditos e quantidade positivos | Sem solução retorna `[]`; parâmetros inválidos falham |

Helpers de listas recebem listas finitas nas chamadas internas. Termos cíclicos construídos manualmente, alterações arbitrárias dos fatos em execução e uso de helpers fora desses modos não integram a interface pública proposta.

## 8. Limitações conhecidas

- O espaço de trilhas é combinatório. O teto de 12, as podas e a coleta limitada reduzem trabalho, mas não tornam viável listar todas as trilhas da grade completa.
- Não são modelados horários, turmas, vagas, oferta sazonal, choques de horário, correquisitos, notas, créditos mínimos por semestre ou equivalências.
- A formatura neste modelo significa concluir as obrigatórias. Uma quota adicional de eletivas exigiria nova regra explícita.
- Semestre sugerido é informativo. Componentes com zero créditos podem aparecer antes dele se não tiverem dependências.
- A checagem de consistência é refeita a cada chamada de planejamento. É simples e adequada ao tamanho desta base; não foi desenvolvido cache de grafos.
- O sistema rejeita ciclos em qualquer região da base, mesmo que não afetem o aluno consultado. Essa decisão conservadora evita planejar sobre uma grade globalmente malformada.
- O executor foi validado em Windows com SWI-Prolog 10.0.2. A execução no computador de apresentação continua sendo a verificação final do ambiente do grupo.

## 9. Testes e isolamento

`consultas_teste.pl` contém um validador de trilha que reconstrói o histórico, verifica créditos, ausência de repetição, pré-requisitos anteriores e conclusão de todas as pendências. Ele verifica o resultado da busca de forma separada de sua implementação.

As outras baterias acrescentam fatos estáticos propositalmente: ciclo, alunos formados, eletiva necessária e referência inválida. São executadas em processos separados e não usam mutações com `assert/retract`. Assim, não contaminam a demonstração ou a base de outras baterias.
