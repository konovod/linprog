# linprog
Idea is to provide wrapper for most performant opensource optimization tools that are available.
This shard is about linear and mixed integer optimization.
According to http://plato.asu.edu/bench.html CLP is pretty good for linear programming, and other projects of COIN-OR (CBC and IPOPT) are fine for nonlinear.

[CoinMP](https://projects.coin-or.org/CoinMP) is decribed as simple API for CLP and CBC (just what I need!), but appears to be buggy and obsolete.

[SYMPHONY](https://projects.coin-or.org/SYMPHONY) looks easy enough to use and to distribute.

---
1. SYMPHONY works, but require few patches to be easily wrappable (namely `extern C` to disable mangling and `#define printf` to disable console spam). I've created fork https://github.com/konovod/SYMPHONY with patches
2. It is distributed under EPL1.0 that is incompatible with GPL, but otherwise pretty permissive.

## Installation
0. Install COIN-OR SYMPHONY from package manager to get all dependencies
1. `git clone https://github.com/konovod/SYMPHONY`
2. `configure && make`
3. copy `SYMPHONY/SYMPHONY/src/.libs/libSym.so.0.0.0` to /usr/lib, create symlink `/usr/lib/libSym.so.1` pointing to it

## Usage

```crystal
require "linalg"
require "linprog"

# linear programming
# x - solution, f - objective value
x, f = Symphony.lpsolve(
  # c - objective function
  c: Linalg::GMat.new([[0, -1]]),
  # a_ub - left part of inequalities
  a_ub: Linalg::GMat.new([[-1, 1], [3, 2], [2, 3]]),
  # b_ub - right part of inequalities
  b_ub: Linalg::GMat.new([[1, 12, 12]]).t,
  # a_eq, b_eq - left and right parts of equalities, can be skipped if empty
  # bounds - constraints to variables
  bounds: {Symphony::Constraint.none, Symphony::Constraint.new(-3.0, Float64::INFINITY)})
pp x, f

# constraint can be same for all vars
x, f = Symphony.lpsolve(
  c: Linalg::GMat.new([[0, -1]]),
  a_ub: Linalg::GMat.new([[-1, 1], [3, 2], [2, 3]]),
  b_ub: Linalg::GMat.new([[1, 12, 12]]).t,
  bounds: Symphony::Constraint.positive)
pp x, f

# tasks can use equalities, inequalities or both
x, f = Symphony.lpsolve(
  c: Linalg::Mat.row([1, 7, 4, 2, 3, 5]),
  a_eq: Linalg::GMat.new([
    [1, 1, 1, 0, 0, 0],
    [0, 0, 0, 1, 1, 1],
    [1, 0, 0, 1, 0, 0],
    [0, 1, 0, 0, 1, 0],
    [0, 0, 1, 0, 0, 1],
  ]),
  b_eq: Linalg::Mat.column([30, 20, 15, 25, 10]))
pp x, f

# integer and mixed integer programming
x, f = Symphony.lpsolve(
  c: Linalg::GMat.new([[0, -1]]),
  a_ub: Linalg::GMat.new([[-1, 1], [3, 2], [2, 3]]),
  b_ub: Linalg::GMat.new([[1, 12, 12]]).t,
  bounds: {Symphony::Constraint.integer, Symphony::Constraint.new(0.0, 6.0, integer: true)})
pp x, f

# there is also more complex interface that allows to save\load problems, but it's WIP, check spec dir for it
```


## Roadmap:

- [ ] warmstarting
- [ ] sensitivity analysis
- [ ] access to solver parameters
- [ ] way to reset solver properly or otherwise avoid memory leak
- [ ] sparse matrix support
- [ ] DSL for problems creation
