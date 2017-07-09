require "linalg"
require "./src/linprog"

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
