require "./spec_helper"

describe Solver do
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
      c: Linalg::Mat.row([1, 7, 4, 2, 3, 5]),
      a_eq: Linalg::GMat.new([
        [1, 1, 1, 0, 0, 0],
        [0, 0, 0, 1, 1, 1],
        [1, 0, 0, 1, 0, 0],
        [0, 1, 0, 0, 1, 0],
        [0, 0, 1, 0, 0, 1],
      ]),
      b_eq: Linalg::Mat.column([30, 20, 15, 25, 10]))
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
end
