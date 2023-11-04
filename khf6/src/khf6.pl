:- use_module(library(lists)).

osszeg_szukites_core([], _, [], [], []).

osszeg_szukites_core([Fx-Fy | RestFs], sor(I, Db), [Dir | RestILs], [NewB | B], [NewE | E]) :-
    ((Fx = I, Dir = [e,w]); (Fx is I - 1, Dir = [s]); (Fx is I + 1, Dir = [n]) -> NewB = Fx-Fy;
        ((Fx = I, subseq0(Dir, [e,w])); (Fx is I - 1, member(s, Dir)); (Fx is I + 1, member(n, Dir)) -> NewE = Fx-Fy; NewE = asd),
        NewB = asd
    ),
    osszeg_szukites_core(RestFs, sor(I, Db), RestILs, B, E).

osszeg_szukites_core([Fx-Fy | RestFs], oszl(J, Db), [Dir | RestILs], [NewB | B], [NewE | E]) :-
    ((Fy = J, Dir = [n,s]); (Fy is J - 1, Dir = [e]); (Fy is J + 1, Dir = [w]) -> NewB = Fx-Fy;
        ((Fy = J, subseq0(Dir, [n,s])); (Fy is J - 1, member(e, Dir)); (Fy is J + 1, member(w, Dir)) -> NewE = Fx-Fy; NewE = asd),
        NewB = asd
    ),
    nl,write(NewB),nl,write(NewE),
    osszeg_szukites_core(RestFs, oszl(J, Db), RestILs, B, E).

osszeg_szukites(Fs, Osszegfeltetel, ILs0, ILs) :-
    osszeg_szukites_core(Fs, Osszegfeltetel, ILs0, B, E),
    length(B, Bl),length(E, El),
    nl,nl,write(Bl),nl,write(El),nl,
    nl,write(B),nl,write(E),nl,
    ILs=[thisistheend],
    !.