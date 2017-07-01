require "./spec_helper"

describe Solver do
  # TODO: Write tests

  it "works" do
    LibSymphony.version
  end

  it "creates and copies environment" do
    s1 = Symphony::Solver.new
    s2 = s1.clone
    pp s1.status, s2.status
    s1.free!
    s2.free!
  end

  it "loads and save mps files" do
    s1 = Symphony::Solver.new
    s1.load "./spec/sample.mps"
    s1.solve
    pp s1.status
  end
end
