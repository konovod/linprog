require "./spec_helper"

owner = LinProg::SymbolProblem.new

describe LinProg do
  describe "DSL" do
    it "can create combination of variables" do
      x = owner.create_var
      y = owner.create_var
      z = 2*x - y + (-y) + 5
      z.should be_a LinProg::LinearCombination
      z.c.should eq 5
      z.k.should eq({x => 2, y => -2})
    end

    it "cleanup variabless with zero coefficient" do
      x = owner.create_var
      y = owner.create_var
      z = 2*x - y
      t = z + y
      w = t * 0
      z.k.should eq({x => 2, y => -1})
      t.k.should eq({x => 2})
      w.k.should be_empty
    end

    it "can create constraints" do
      x = owner.create_var
      y = owner.create_var
      z = x*2 <= y - 5
      t = x.eq 2
      z.is_equality.should be_false
      z.combination.should eq x*2 - y + 5

      t.is_equality.should be_true
      t.combination.should eq x - 2
    end

    it "can solve problems" do
      task = LinProg::SymbolProblem.new
      x = task.create_var(bound: LinProg::Bound.integer)
      y = task.create_var(bound: LinProg::Bound.new(0.0, 6.0, true))
      task.st(x + 1 >= y)
      task.st(3*x + 2*y <= 12)
      task.st(2*x + 3*y <= 12)
      task.maximize(y)
      task.solve
      x.value.should eq 1
      y.value.should eq 2
    end
  end
end
