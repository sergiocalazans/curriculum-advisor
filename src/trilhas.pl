








% existe_ciclo(Disciplina)
% Verdadeiro se a disciplina é pré-requisito transitivo dela mesma
% (base de dados malformada).
existe_ciclo(Disciplina) :-
    prerequisito_transitivo(Disciplina, Disciplina).

