require "./spec_helper"

describe Linprog do
  # TODO: Write tests

  it "works" do
    LibSymphony.version
  end

  it "creates and copies environment" do
    s1 = Symphony::Solver.new
    s1.load "./spec/sample.mps"
    s2 = s1.clone
    s1.solve
    s1.status.should eq Symphony::Status::OPTIMAL_SOLUTION_FOUND
    s2.status.should eq Symphony::Status::NO_SOLUTION
    s1.free!
    s2.free!
  end

  it "loads and save mps files" do
    s1 = Symphony::Solver.new
    s1.load "./spec/sample.mps"
    s1.solve
    s1.status.should eq Symphony::Status::OPTIMAL_SOLUTION_FOUND
    s1.free!
  end
  pending "loads and save gmpl files" do
    s1 = Symphony::Solver.new
    s1.load_gmpl "./spec/sample.mod", "./spec/sample.dat"
    s1.solve
    s1.status.should eq Symphony::Status::OPTIMAL_SOLUTION_FOUND
    s1.free!
  end

  it "loads and save lp files" do
    s1 = Symphony::Solver.new
    s1.load "./spec/block_milp.lp", Symphony::FileFormat::LP
    s1.solve
    s1.status.should eq Symphony::Status::OPTIMAL_SOLUTION_FOUND
    s1.free!
  end

  it "loads explicit problem" do
    s1 = Symphony::Solver.new
    problem = Symphony::Problem.from_dense(
      c: LA::Mat.row([1, 7, 4, 2, 3, 5]),
      a_eq: LA::GMat.new([
        [1, 1, 1, 0, 0, 0],
        [0, 0, 0, 1, 1, 1],
        [1, 0, 0, 1, 0, 0],
        [0, 1, 0, 0, 1, 0],
        [0, 0, 1, 0, 0, 1],
      ]),
      b_eq: LA::Mat.column([30, 20, 15, 25, 10]))
    s1.load_explicit(problem)
    s1.solve
    s1.status.should eq Symphony::Status::OPTIMAL_SOLUTION_FOUND
    s1.solution_x.should eq [15, 5, 10, 0, 20, 0]
    s1.solution_f.should eq 150
    s1.other_solutions.size.should be > 0
    s1.free!
  end

  it "allows to set and get optimization direction" do
    s1 = Symphony::Solver.new
    s1.direction.should eq Symphony::Direction::Minimize
    s1.direction = Symphony::Direction::Maximize
    s1.direction.should eq Symphony::Direction::Maximize
    s1.free!
  end

  it "variables can be constrained" do
    c = LA::GMat.new [[-1, 4]]
    a = LA::GMat.new [[-3, 1], [1, 2]]
    b = LA::GMat.new([[6, 4]]).t
    x0_bounds = Symphony::Constraint.none
    x1_bounds = Symphony::Constraint.new(-3.0, Float64::INFINITY)
    solver = Symphony::Solver.new
    solver.load_explicit Symphony::Problem.from_dense(
      a_ub: a,
      b_ub: b,
      c: c,
      bounds: {x0_bounds, x1_bounds}
    )
    solver.solve
    solver.solution_x.should eq [10, -3]
  end

  it "can solve integer problems" do
    c = LA::GMat.new [[0, -1]]
    a = LA::GMat.new [[-1, 1], [3, 2], [2, 3]]
    b = LA::GMat.new([[1, 12, 12]]).t
    x0_bounds = Symphony::Constraint.positive
    x1_bounds = Symphony::Constraint.positive
    solver = Symphony::Solver.new
    solver.load_explicit Symphony::Problem.from_dense(
      a_ub: a,
      b_ub: b,
      c: c,
      bounds: {x0_bounds, x1_bounds}
    )
    solver.solve
    solver.solution_f.should be_close -2.8, 1e-6

    solver.reset
    x0_bounds = Symphony::Constraint.integer
    x1_bounds = Symphony::Constraint.integer
    solver.load_explicit Symphony::Problem.from_dense(
      a_ub: a,
      b_ub: b,
      c: c,
      bounds: {x0_bounds, x1_bounds}
    )
    solver.solve
    solver.solution_f.should eq -2
  end

  it "allows simplified interface" do
    x, f = Symphony.lpsolve(
      c: LA::GMat.new([[0, -1]]),
      a_ub: LA::GMat.new([[-1, 1], [3, 2], [2, 3]]),
      b_ub: LA::GMat.new([[1, 12, 12]]).t,
      bounds: {Symphony::Constraint.integer, Symphony::Constraint.new(0.0, 6.0, true)}
    )
    x.should eq [1, 2]
    f.should eq -2
  end
end
