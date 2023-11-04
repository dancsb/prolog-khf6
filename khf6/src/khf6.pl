:- use_module(library(lists)).

osszeg_szukites_core([], _, [], [], []).

osszeg_szukites_core([Fx-Fy | RestFs], sor(I, Db), [Dir | RestILs], [NewB | B], [NewE | E]) :-
    (((Fx = I, Dir = [e,w]); (Fx is I - 1, Dir = [s]); (Fx is I + 1, Dir = [n])) -> NewB = Fx-Fy, NewE = [];
        (((Fx = I, subseq0(Dir, [e,w])); (Fx is I - 1, member(s, Dir)); (Fx is I + 1, member(n, Dir))) -> NewE = Fx-Fy; NewE = []),
        NewB = []
    ),
    osszeg_szukites_core(RestFs, sor(I, Db), RestILs, B, E).

osszeg_szukites_core([Fx-Fy | RestFs], oszl(J, Db), [Dir | RestILs], [NewB | B], [NewE | E]) :-
    (((Fy = J, Dir = [n,s]); (Fy is J - 1, Dir = [e]); (Fy is J + 1, Dir = [w])) -> NewB = Fx-Fy, NewE = [];
        (((Fy = J, subseq0(Dir, [n,s])); (Fy is J - 1, member(e, Dir)); (Fy is J + 1, member(w, Dir))) -> NewE = Fx-Fy; NewE = []),
        NewB = []
    ),
    osszeg_szukites_core(RestFs, oszl(J, Db), RestILs, B, E).

filter_ils_core(Fx-_, sor(I, _), Dir, Case, NewDir) :-
    (member(e, Dir), ((Fx = I, Case = ii); (Fx \= I, Case = iii)) -> EDir = [e]; EDir = []),
    (member(n, Dir), ((Fx is I + 1, Case = ii); (\+Fx is I + 1, Case = iii)) -> append(EDir, [n], NDir); NDir = EDir),
    (member(s, Dir), ((Fx is I - 1, Case = ii); (\+Fx is I - 1, Case = iii)) -> append(NDir, [s], SDir); SDir = NDir),
    (member(w, Dir), ((Fx = I, Case = ii); (Fx \= I, Case = iii)) -> append(SDir, [w], WDir); WDir = SDir),
    NewDir = WDir.

filter_ils_core(_-Fy, oszl(J, _), Dir, Case, NewDir) :-
    (member(e, Dir), ((Fy is J - 1, Case = ii); (\+Fy is J - 1, Case = iii)) -> EDir = [e]; EDir = []),
    (member(n, Dir), ((Fy = J, Case = ii); (Fy \= J, Case = iii)) -> append(EDir, [n], NDir); NDir = EDir),
    (member(s, Dir), ((Fy = J, Case = ii); (Fy \= J, Case = iii)) -> append(NDir, [s], SDir); SDir = NDir),
    (member(w, Dir), ((Fy is J + 1, Case = ii); (\+Fy is J + 1, Case = iii)) -> append(SDir, [w], WDir); WDir = SDir),
    NewDir = WDir.

filter_ils([], _, [], _, _, []).

filter_ils([Fs | RestFs], Osszegfeltetel, [Dir | RestILs0], E, Case, [NewDir | RestILs]) :-
    (member(Fs, E) -> filter_ils_core(Fs, Osszegfeltetel, Dir, Case, NewDir); NewDir = Dir),
    filter_ils(RestFs, Osszegfeltetel, RestILs0, E, Case, RestILs).

filter(X) :- X = [].

osszeg_szukites(Fs, Osszegfeltetel, ILs0, ILs) :-
    osszeg_szukites_core(Fs, Osszegfeltetel, ILs0, B0, E0),
    exclude(filter, B0, B), length(B, Bl),
    exclude(filter, E0, E), length(E, El),
    BEl is Bl + El,
    arg(2, Osszegfeltetel, Db),
    ((BEl < Db; Bl > Db) -> ILs = [];
        (BEl = Db -> filter_ils(Fs, Osszegfeltetel, ILs0, E, ii, ILs);
            (Bl = Db -> filter_ils(Fs, Osszegfeltetel, ILs0, E, iii, ILs); fail)
        )
    ),
    !.