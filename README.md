# solver
Idea is to provide wrapper for most performant opensource optimization tools that are available.

According to http://plato.asu.edu/bench.html CLP is pretty good for linear programming, and other projects of COIN-OR (CBC and IPOPT) are fine for nonlinear.

IPOPT is pretty complex to even get installed, so it perhaps doesn't fit in the general-purpose scientific library.

[CoinMP](https://projects.coin-or.org/CoinMP) is decribed as simple API for CLP and CBC (just what I need!), but appears to be buggy and obsolete.

Will check if [SYMPHONY](https://projects.coin-or.org/SYMPHONY) is easy enough to use and to distribute.

Fallback is to use [CLP](https://projects.coin-or.org/CLP) (and maybe [CBC](https://projects.coin-or.org/Cbc)?) directly and then go check other projects for quadratic\nonlinear tasks.

---

Results:
1. SYMPHONY works, but require few patches to be easily wrappable. I've created fork https://github.com/konovod/SYMPHONY with patches
2. It is distributed under EPL1.0 that is incompatible with GPL, but otherwise pretty permissive.

#Installation
0. Install COIN-OR SYMPHONY from package manager to get all dependencies
1. `git clone https://github.com/konovod/SYMPHONY`
2. `configure && make`
3. copy `SYMPHONY/SYMPHONY/src/.libs/libSym.so.0.0.0` to /usr/lib, create symlink `/usr/lib/libSym.so.1` pointing to it
