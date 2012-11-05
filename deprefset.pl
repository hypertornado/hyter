% Prolog procedures for generating all possible reference translations.
% Goal: mimic HyTERs but be more compact when the target language is
% morphologically rich and allows somewhat freer word order.
% Ondrej Bojar, bojar@ufal.mff.cuni.cz
%
% usage:
% 1. create a file with sentence annotations, sample.pl
% 2. finish the file with:
%      :- consult('deprefset.pl').
% 3. run:
%      yap -L sample.pl | less

demo :-
  sent(Root, S),
  repeat, !, 
  ref(Root, S, Tgt),
  nice_write(Tgt),
  fail.

nice_write(List) :-
  List = [H|T]
  ->
  (
    T = []
    -> % the last word of the sentence is H
    nice_write_word(H), nl
    ;
    nice_write_word(H),
    write(' '),
    nice_write(T)
  )
  ;
  nl.

nice_write_word(Word) :-
  write(Word).

% construct all reference translations for Src starting at the Root word of Tgt
ref(Root, Src, Tgt) :-
  not(var(Src)),
  ref([Root], Src, [], [], Tgt).

% top-down generation of all reference translations
ref(Constr, InSrc, OutSrc, InTgt, OutTgt) :-
  % pick a root that satisfies our constraints
  % write('searching for '), write(Constr), nl,
  % write('  in '), write(InSrc), nl,
  find_option(Constr, Head, InSrc, TSrc),
  % write('got option: '), write(Head), nl,
  Head = option(_CoveredWords, _MyFullConstraints, ToProduceORList),
  % Expand the OR-list
  explode_orlist(ToProduceORList, ToProduce),
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
%   extract source word(s) from the word list and find a translation option
%   that translates them *and* satisfies the given Constr
%   While satisfying the Constr and the incoming constraints of the option,
%   modify the option by expanding variables. This is unification in a top-down
%   manner.
find_option(Constr, Out, InWords, OutWords) :-
  % write(InWords), nl,
  % pick any option
  (
  % either a regular option with only atomic constraints
  option(CoveredWords, MyFullConstraints, Produced),
  VarRequests = []
  ;
  % or an option that uses vars
  option(CoveredWords, MyFullConstraints, VarRequests, Produced)
  ),
  % make sure it covers some of the words we still have to cover
  extract_all(CoveredWords, InWords, OutWords),
  % ensure that the atomic constraints are satisfied
  covered(Constr, MyFullConstraints, CoveredWords),
  % write([' validated: ', Constr, ' by ', MyFullConstraints, ' and ', CoveredWords]), nl,
  (
  VarRequests = [] ->
    % there are no vars to carry over
    UseProduced = Produced
  ; % need to pick vals from Constr as required by vars
    pick_var_values(VarRequests, Constr, VarAssignments),
    % apply them to all our slots as needed
    apply_var_values(VarAssignments, Produced, UseProduced)
  ),
  Out = option(CoveredWords, MyFullConstraints, UseProduced).

% given a list of requests like share(VARNAME, [fem, foo, num]) where the list
% can contain atomic constraints as well as exclusion group names
% produce a list with var assignments like assign(VARNAME, [foo, pl]).
pick_var_values([], _Constr, []).
pick_var_values([share(VarName, Requests) | TailRequests], Constr,
    [assign(VarName, Found) | TailAssignments]) :-
  pick_var_values(TailRequests, Constr, TailAssignments),
  pick_constraints(Requests, Constr, [], Found). % XXX should remove duplicates from Found

% given a list of atomic constraints of exclusion group names, extract them
% from Constr, if they are there
pick_constraints([], _, Aku, Aku).
pick_constraints([C|T], Constr, IAku, OAku) :-
  (
  exclusive(C, GroupOfAtoms) ->
    % this was an exclusion group name
    pick_constraints(GroupOfAtoms, Constr, IAku, TAku)
  ; % this is a regular atom name
    (
    member(C, Constr) ->
      % the atom is in constr, add it to Aku
      TAku = [C | IAku]
    ; % the atom was not there, aku unchanged
      TAku = IAku
    )
  ),
  % process the tail of requests
  pick_constraints(T, Constr, TAku, OAku).

% given the production list, replace all vars with their values
% apply_var_values(VarAssignments, Produced, UseProduced).
apply_var_values(_VarAssignments, [], []).
apply_var_values(VarAssignments, [H|T], [OutH|OutT]) :-
  apply_var_values(VarAssignments, T, OutT), % copy tail
  (
  H = [_|_] ->
    % this is a slot, resolve the vars in it
    apply_vars_to_slot(VarAssignments, H, OutH)
  ; H = or(List) ->
    % this is an or-list, fill the vars in it too
    apply_var_values(VarAssignments, List, TList),
      % hack to ensure the one more level of lists does not harm
    apply_var_values_to_list(VarAssignments, TList, OList),
    OutH = or(OList)
  ; % this is an output token, just copy it
    OutH = H
  ).

apply_var_values_to_list(VA, [], []).
apply_var_values_to_list(VA, [H|T], [OH | OT]) :-
  apply_var_values(VA, H, OH),
  apply_var_values_to_list(VA, T, OT).

apply_vars_to_slot(_VarAssignments, [], []).
apply_vars_to_slot(VarAssignments, [H|T], OutT) :-
  apply_vars_to_slot(VarAssignments, T, TOutT),
  (
  H = share(VarName) -> % this is a var request, copy the vals
    (
    get_var_values(VarAssignments, VarName, Vals) ->
      append(Vals, TOutT, OutT)
    ;
    write('Error: Variable '), write(VarName),
    write(' not found in '), write(VarAssignments), nl,
    abort
    )
  ; % this is a regular constraint, keep it here
    OutT = [H | TOutT]
  ).

get_var_values([assign(Name, Val) | T], Needle, Out) :-
  Name = Needle ->
    Out = Val
  ;
  get_var_values(T, Needle, Out).

% covered(+Constr, +List) checks if all constraints in Constr are covered in
% List; it also guarantees that exclusive constraints are not violated
covered([], _, _).
covered([C|Rest], Constr, CoveredWords) :-
  % write('Checking if: '), write(covered([C|Rest], Constr, CoveredWords)), nl,
  (
  % constraint explicitly satisfied
  %write(['Is ', C, ' explicitly listed in ', Constr, '?']), nl,
  extract_member(C, Constr, _)
  ;
  % constraint asks that we translate the word, and we do.
  %write(['Is ', C, ' covered as word among ', CoveredWords, '?']), nl,
  extract_member(C, CoveredWords, _)
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
  exclusive(_CategoryName, Exclusions),
  member(C, Exclusions),
  Out = Exclusions.

% extract_member ensures to find the given element and removes it from the list
extract_member(Needle, [H|T], Out) :-
  Needle = H ->
    Out = T
  ;
  extract_member(Needle, T, T2),
  Out = [H|T2].

% the nondeterministic version, emits all possible words (output, input, output)
extract_member_oio(H, [H|T], T).
extract_member_oio(H2, [H|T], [H|T2]) :-
  extract_member_oio(H2, T, T2).


extract_all([], Aku, Aku).
extract_all([X|Tail], IAku, OAku) :-
  extract_member(X, IAku, TAku),
  extract_all(Tail, TAku, OAku).

member(X, [H|T]) :-
  X = H
  ;
  % X \= H,
  member(X, T).

append([], Aku, Aku).
append([H|T], ToAppend, Out) :-
  append(T, ToAppend, OutTail),
  Out = [H|OutTail].




% explodes/flattens all variants of an or-list.
% an or-list is a list where some members 
% Identities for simple writing:
%   []           ... is interpreted as []
%   [A, B]       ... is interpreted as [interpret(A), interpret(B)]
%   [or([])]     ... nonsense
%   [or([X])]    ... nonsense
%   [or([A, B])] ... interpret(A)   or   interpret(B)
explode_orlist([], []).
explode_orlist([H | T], Out) :-
  (
  H = or(X)
  ->
    (
    (X = []; X = [ _ | _ ]) ->
      member(VariantS, X), % get each of the variants
      % write('Considering '), write(Variant), write(' from '), write(X), nl,
      raise_singleton_to_list(VariantS, Variant),
      explode_orlist(Variant, H2) % interpret it
    ;
    write('Nonsense, or(...) must contain a list, got '), write(H), nl,
    abort
    )
  ; % H is not or(...) but rather an item
    H2 = [H]
  ),
  explode_orlist(T, T2),
  append(H2, T2, Out).


raise_singleton_to_list(X, Out) :-
  X = [] ->
    Out = [] 
  ; X = [_|_] ->
    Out = X
  ;
    Out = [X]
  .

exclusive(_,_).
option(_,_,_,_).


% autorun: Once compiled, run the demo and halt.
% I use the ';' because demo contains a repeat-fail loop
:- demo; halt.
