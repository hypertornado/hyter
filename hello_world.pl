% A sample English sentence with manually created translations.
% Goal: mimic HyTERs but be more compact when the target language is
% morphologically rich and allows somewhat freer word order.
% Ondrej Bojar, bojar@ufal.mff.cuni.cz
%
% usage, e.g.: yap -L cssd.pl | wc -l

demo :-
  sent(Root, S),
  repeat, !, 
  ref(Root, S, Tgt),
  write(Tgt),
  nl,
  fail.

% construct all reference translations for Src starting at the Root word of Tgt
ref(Root, Src, Tgt) :-
  not(var(Src)),
  ref([Root], Src, [], [], Tgt).

% top-down generation of all reference translations
ref(Constr, InSrc, OutSrc, InTgt, OutTgt) :-
  % pick a root that satisfies our constraints
  %write('searching for '), write(Constr), nl,
  %write('  in '), write(InSrc), nl,
  find_option(Constr, Head, InSrc, TSrc),
  %write('got option: '), write(Head), nl,
  Head = option(CoveredWords, _MyFullConstraints, ToProduce),
  % construct all subtrees
  constr_list(ToProduce, TSrc, OutSrc, InTgt, OutTgt).

constr_list([], A, A, B, B).
constr_list([Constr | Rest], InSrc, OutSrc, InTgt, OutTgt) :-
  %write(constr_list([Constr|Rest], InSrc, OutSrc, InTgt, OutTgt)), nl,
  (
  % if Constr is a list, then it is a requirement on a subphrase
  (Constr = [_|_]; Constr = [])
  ->
    (
    extract_member(opt, Constr, ConstrMinusOpt)
    ->
    % optional slots can be filled or skipped
      (
      ref(ConstrMinusOpt, InSrc, TSrc, InTgt, TTgt) % fill
      ;
      TSrc = InSrc, TTgt = InTgt  % skip
      )
    ; % no "opt", must fill
      ref(Constr, InSrc, TSrc, InTgt, TTgt)
    ),
    constr_list(Rest, TSrc, OutSrc, TTgt, OutTgt) % construct the rest
  ;
    % Constr is just an output word to be produced
    append(InTgt, [Constr], TTgt), % inefficient, but I am too lazy to reverse
    constr_list(Rest, InSrc, OutSrc, TTgt, OutTgt)
  ).

% find_option(+Constr, -Option, +-WordsAccumulator)
%   extract a source word from the word list and find its translation option
%   that satisfies the given Constr
find_option(Constr, Out, InWords, OutWords) :-
%  write(InWords), nl,
  extract_member(Word, InWords, TWords),
  % find the option that covers this word and perhaps other words
  option(CoveredWords, MyFullConstraints, Produced),
  CoveredWords = [Word|RemainingWords],
  % ensure all remaining words can still be covered
  extract_all(RemainingWords, TWords, OutWords),
  % ensure that the constraints are satisfied
  %write(['validating: ', Constr, ' by ', MyFullConstraints, ' and ', CoveredWords]), nl,
  covered(Constr, MyFullConstraints, CoveredWords),
  %write([' validated: ', Constr, ' by ', MyFullConstraints, ' and ', CoveredWords]), nl,
  Out
  = option(CoveredWords, MyFullConstraints, Produced).

% covered(+Constr, +List) checks if all constraints in Constr are covered in
% List; it also guarantees that exclusive constraints are not violated
covered([], _, _).
covered([C|Rest], Constr, CoveredWords) :-
  %write(covered([C|Rest], Constr, CoveredWords)), nl,
  (
  % constraint explicitly satisfied
  %write(['Is ', C, ' explicitly listed in ', Constr, '?']), nl,
  member(C, Constr)
  ;
  % constraint asks that we translate the word, and we do.
  %write(['Is ', C, ' covered as word among ', CoveredWords, '?']), nl,
  member(C, CoveredWords)
  ;
  % constraint not implicitly denied
  (
  exist_exclusion(C, Exclusions)
    ->
    empty_intersection(Exclusions, Constr)
  )
  ),
  covered(Rest, Constr, CoveredWords). % check the tail

% auxiliary predicates

empty_intersection([], _).
empty_intersection([H|T], List) :-
  not(member(H, List)),
  empty_intersection(T, List).

exist_exclusion(C, Out) :-
  not(var(C)),
  exclusive(Exclusions),
  member(C, Exclusions),
  Out = Exclusions.

extract_member(H, [H|T], T).
extract_member(H2, [H|T], [H|T2]) :-
  extract_member(H2, T, T2).

extract_all([], Aku, Aku).
extract_all([X|Tail], IAku, OAku) :-
  extract_member(X, IAku, TAku),
  extract_all(Tail, TAku, OAku).

member(X, [H|T]) :-
  X = H
  ;
  X \= H,
  member(X, T).

append([], Aku, Aku).
append([H|T], ToAppend, Out) :-
  append(T, ToAppend, OutTail),
  Out = [H|OutTail].





%%%% Language-specific data


% Putting several atoms on an 'exclusive' list ensures that if e.g. 'fem' is
% required and the given item provides 'masc', they do not combine.
exclusive([fem, masc, neut, inan]).
exclusive([sg, pl]).
exclusive([nom, gen, dat, acc]).



%%%% Sentence-specific data

% the sentence to "translate", i.e. construct all references for
% the first argument specifies which is the main root word of the sentence
%sent(hello, [hello, world]).
%sent(lacks, [cssd, lacks, knowledge, of, both, voldemort, and, candy, bars]).
%sent(lacks, [cssd, lacks, knowledge]).
%sent(of, [of, both, voldemort, and, candy, bars]).


% An 'option' (or translation option, if you wish) describes, which source
% words it covers, which constraints it satisfies and which words it produces.
% option:
%   covered tokens (an unsorted set)
%   constraints we satisfy
%   target list, mixing output forms (atoms) and slots (lists of constraints)

% Specifying slots:
%   The list of output symbols can include slots, e.g.:
%       [ prague, opt, adj, fem, sg, dat ]
%   A slot is formally just a list of constraints, each of which must be
%   satisfied.
%   The constraints are of several types:
%   a) operational flags:
%        opt  ... this slot may be skipped
%   b) words covered:
%        prague ... this source word has to be (immediately!) covered by the
%                   slot filler; in practice, it would be better to support
%                   indirect covering, i.e. the whole subtree of the slot
%                   has to cover this word
%   c) target-side properties:
%        adj  ... the slot filler syntactically has to be an adjective
%        fem  ... in feminine gender, ...

%option([hello], [], [[],ahooj]).

%option([world], [], [svete]).

sent(t_1, [t_1, t_2]).

option([t_1], [t_3], [t_4, []]).
option([t_2], [t_3], [t_4]).

% autorun: Once compiled, run the demo and halt.
% I use the ';' because demo contains a repeat-fail loop
:- demo; halt.