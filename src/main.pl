:- consult('curriculum.pl').      % Camada 1: fatos
:- consult('elegibilidade.pl').   % Camada 2: regras de elegibilidade
:- consult('trilhas.pl').         % Camada 3: fecho transitivo e trilhas

% demo/0
% Exercita, em sequência, as três camadas com a aluna carla.

%demo :-
    %continue glaucia