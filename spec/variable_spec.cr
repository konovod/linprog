require "./spec_helper"

describe LinProg do
  it "can create combination of variables" do
    x = LinProg::Variable.new
    y = LinProg::Variable.new
    z = 2*x - y + (-y) + 5
    z.should be_a LinProg::LinearCombination
    z.c.should eq 5
    z.k.should eq({x => 2, y => -2})
  end

  it "cleanup variabless with zero coefficient" do
    x = LinProg::Variable.new
    y = LinProg::Variable.new
    z = 2*x - y
    t = z + y
    w = t * 0
    z.k.should eq({x => 2, y => -1})
    t.k.should eq({x => 2})
    w.k.should be_empty
  end
end
