# solver
Idea is to provide wrapper for most performant opensource optimization tools that are available.

According to http://plato.asu.edu/bench.html CLP is pretty good for linear programming, and other projects of COIN-OR (CBC and IPOPT) are fine for nonlinear. 

IPOPT is pretty complex to even get installed, so it perhaps doesn't fit in the general-purpose scientific library. 

[CoinMP](https://projects.coin-or.org/CoinMP) is decribed as simple API for CLP and CBC (just what I need!), but appears to be buggy and obsolete.

Will check if [SYMPHONY](https://projects.coin-or.org/SYMPHONY) is easy enough to use and to distribute.

Fallback is to use [CLP](https://projects.coin-or.org/CLP) (and maybe [CBC](https://projects.coin-or.org/Cbc)?) directly and then go check other projects for quadratic\nonlinear tasks.
