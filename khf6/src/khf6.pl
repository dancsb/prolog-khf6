% :- type parcMutató ==    int-int.          % egy parcella helyét meghatározó egészszám-pár
% :- type fák ==           list(parcMutató). % a fák helyeit tartalmazó lista
% :- type irány    --->    n                 % észak 
%                        ; e                 % kelet 
%                        ; s                 % dél   
%                        ; w.                % nyugat
% :- type iránylista ==    list(irany).      % egy adott fához rendelt sátor
                                             % lehetséges irányait megadó lista
% :- type iránylisták ==   list(iránylista). % az összes fa iránylistája

% :- type összegfeltétel
%                     ==   sor(int, int)     % sor(I,Db): az I-edik sorbeli sátrak száma Db
%                        ; oszl(int, int).   % oszl(J,Db): a J-edik oszlopbeli sátrak száma Db

% :- pred osszeg_szukites(fák::in,           % Fs
%                         összegfeltétel::in,% Osszegfeltetel
%                         iránylisták::in,   % ILs0
%                         iránylisták::out)  % ILs
:- use_module(library(lists)). % SICStus lists library betöltése

% Elfogytak a fák
osszeg_szukites_core([], _, [], [], []).

% A biztosan illetve esetleg egy adott sorba mutató fák meghatározása rekurzívan. A nem megfeleő elemeket üres listák jelölik.
osszeg_szukites_core([Fx-Fy | RestFs], sor(I, _), [Dir | RestILs], [NewB | B], [NewE | E]) :-
    (((Fx = I, subseq0([e,w], Dir)); (Fx is I - 1, Dir = [s]); (Fx is I + 1, Dir = [n])) -> NewB = Fx-Fy, NewE = [];
        (((Fx = I, (member(e, Dir); member(w, Dir))); (Fx is I - 1, member(s, Dir)); (Fx is I + 1, member(n, Dir))) -> NewE = Fx-Fy; NewE = []),
        NewB = []
    ),
    osszeg_szukites_core(RestFs, sor(I, _), RestILs, B, E).

% A biztosan illetve esetleg egy adott oszlopba mutató fák meghatározása rekurzívan. A nem megfeleő elemeket üres listák jelölik.
osszeg_szukites_core([Fx-Fy | RestFs], oszl(J, _), [Dir | RestILs], [NewB | B], [NewE | E]) :-
    (((Fy = J, subseq0([n,s], Dir)); (Fy is J - 1, Dir = [e]); (Fy is J + 1, Dir = [w])) -> NewB = Fx-Fy, NewE = [];
        (((Fy = J, (member(n, Dir); member(s, Dir))); (Fy is J - 1, member(e, Dir)); (Fy is J + 1, member(w, Dir))) -> NewE = Fx-Fy; NewE = []),
        NewB = []
    ),
    osszeg_szukites_core(RestFs, oszl(J, _), RestILs, B, E).

% Adott sorba esetlegesen mutató fa meglévő iránylistájának újrartékelése, szűkítése. Egy adott irány akkor maradhat, ha eddig is volt, és az ii. vagy iii. eset szerint maradnia kell.
filter_ils_core(Fx-_, sor(I, _), Dir, Case, NewDir) :-
    (member(e, Dir), ((Fx = I, Case = ii); (Fx \= I, Case = iii)) -> EDir = [e]; EDir = []), % Kelet
    (member(n, Dir), ((Fx is I + 1, Case = ii); (\+Fx is I + 1, Case = iii)) -> append(EDir, [n], NDir); NDir = EDir), % Észak
    (member(s, Dir), ((Fx is I - 1, Case = ii); (\+Fx is I - 1, Case = iii)) -> append(NDir, [s], SDir); SDir = NDir), % Dél
    (member(w, Dir), ((Fx = I, Case = ii); (Fx \= I, Case = iii)) -> append(SDir, [w], WDir); WDir = SDir), % Nyugat
    NewDir = WDir.

% Adott oszlopba esetlegesen mutató fa meglévő iránylistájának újrartékelése, szűkítése. Egy adott irány akkor maradhat, ha eddig is volt, és az ii. vagy iii. eset szerint maradnia kell.
filter_ils_core(_-Fy, oszl(J, _), Dir, Case, NewDir) :-
    (member(e, Dir), ((Fy is J - 1, Case = ii); (\+Fy is J - 1, Case = iii)) -> EDir = [e]; EDir = []), % Kelet
    (member(n, Dir), ((Fy = J, Case = ii); (Fy \= J, Case = iii)) -> append(EDir, [n], NDir); NDir = EDir), % Észak
    (member(s, Dir), ((Fy = J, Case = ii); (Fy \= J, Case = iii)) -> append(NDir, [s], SDir); SDir = NDir), % Dél
    (member(w, Dir), ((Fy is J + 1, Case = ii); (\+Fy is J + 1, Case = iii)) -> append(SDir, [w], WDir); WDir = SDir), % Nyugat
    NewDir = WDir.

% Elfogytak a fák
filter_ils([], _, [], _, _, []).

% Iránylisták szűkítése rekurzívan
filter_ils([Fs | RestFs], Osszegfeltetel, [Dir | RestILs0], E, Case, [NewDir | RestILs]) :-
    (member(Fs, E) -> filter_ils_core(Fs, Osszegfeltetel, Dir, Case, NewDir); NewDir = Dir),
    filter_ils(RestFs, Osszegfeltetel, RestILs0, E, Case, RestILs).

filter(X) :- X = []. % Üres listák szűrése

osszeg_szukites(Fs, Osszegfeltetel, ILs0, ILs) :-
    osszeg_szukites_core(Fs, Osszegfeltetel, ILs0, B0, E0), % A biztosan illetve esetleg egy adott sorba/oszlopba mutató fák kigyűjtése
    exclude(filter, B0, B), length(B, Bl), % A nem megfelelő elemek szűrése, a biztosan egy adott sorba/oszlopba mutató fák megszámlálása
    exclude(filter, E0, E), length(E, El), % A nem megfelelő elemek szűrése, az esetleg egy adott sorba/oszlopba mutató fák megszámlálása
    BEl is Bl + El, % b + e számítása
    arg(2, Osszegfeltetel, Db), % sor/oszlop darabszám meghatározása
    ((BEl < Db; Bl > Db) -> ILs = []; % i. vagy iv. eset
        (BEl = Db -> filter_ils(Fs, Osszegfeltetel, ILs0, E, ii, ILs); % ii. eset
            (Bl = Db -> filter_ils(Fs, Osszegfeltetel, ILs0, E, iii, ILs); % iii. eset
                fail % Egyik sem
            )
        )
    ),
    !. % cut