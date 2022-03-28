require "./spec_helper"

describe "GLPK" do
  it "works" do
    puts "GLPK Version: " + String.new(LibGLPK.version)
  end

  it "solve dense problems" do
    c = LA::GMat.new [[0, -1]]
    a = LA::GMat.new [[-1, 1], [3, 2], [2, 3]]
    b = LA::GMat.new([[1, 12, 12]]).t
    x0_bounds = LinProg::Bound.positive
    x1_bounds = LinProg::Bound.positive

    x, f = GLPK.solve(
      a_ub: a,
      b_ub: b,
      c: c,
      bounds: {x0_bounds, x1_bounds}
    )
    f.should be_close -2.8, 1e-6
  end

  it "solve MIP problems" do
    x, f = GLPK.solve(
      c: LA::GMat.new([[0, -1]]),
      a_ub: LA::GMat.new([[-1, 1], [3, 2], [2, 3]]),
      b_ub: LA::GMat.new([[1, 12, 12]]).t,
      bounds: {LinProg::Bound.integer, LinProg::Bound.new(0.0, 6.0, true)}
    )
    x.should eq [1, 2]
    f.should eq -2
  end
end
