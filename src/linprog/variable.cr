module LinProg
  class Variable
    @@param_id = 0u64
    @bound : Bound = Bound.none
    getter id : UInt64

    def value : Float64
      # TODO
      0.0
    end

    def initialize(@bound = Bound.none)
      @@param_id += 1
      @id = @@param_id
    end

    def +(other)
      LinearCombination.new(self) + other
    end

    def -(other)
      LinearCombination.new(self) - other
    end

    def *(other)
      LinearCombination.new(self) * other
    end

    def /(other)
      LinearCombination.new(self) / other
    end

    def -
      -LinearCombination.new(self)
    end

    def inspect(io)
      io << "LinProg::Variable#" << @id
      if @bound != Bound.none
        io << "(" << @bound << ")"
      end
    end

    def to_s(io)
      io << "Var" << @id
      if @bound != Bound.none
        io << "(" << @bound << ")"
      end
    end
  end

  struct LinearCombination
    # TODO - true stack allocation
    getter k = Hash(Variable, Float64).new(0.0)
    property c : Float64 = 0

    def initialize(var : Variable)
      k[var] = 1.0
    end

    def initialize(@k, @c)
    end

    def value : Float64
      c + k.sum { |param, scale| param.value*scale }
    end

    def clone
      LinearCombination.new(@k.dup, @c)
    end

    def +(x : Number)
      LinearCombination.new(@k.dup, @c + x)
    end

    def -(x : Number)
      self + (-x)
    end

    def *(x : Number)
      return LinearCombination.new(typeof(@k).new, 0.0) if x.zero?
      LinearCombination.new(@k.transform_values { |v| v*x }, @c * x)
    end

    def /(x : Number)
      self*(1.0 / x)
    end

    def -
      self*(-1)
    end

    def cleanup
      @k.reject! { |param, scale| scale == 0 }
      self
    end

    def +(other : LinearCombination)
      LinearCombination.new(@k.dup.merge(other.k) { |p1, v1, v2| v1 + v2 }, c + other.c).cleanup
    end

    def +(other : Variable)
      self + LinearCombination.new(other)
    end

    def -(other : Variable)
      self - LinearCombination.new(other)
    end

    def -(other : LinearCombination)
      self + (-other)
    end

    def ==(other)
      Expression.new(true, self - other)
    end

    def <=(other)
      Expression.new(true, self - other)
    end

    def >=(other)
      Expression.new(true, other - self)
    end
  end

  class Expression
    property is_equality : Bool
    getter combination : LinearCombination

    def initialize(@is_equality, @combination)
    end

    def satisfied
      eval = @combination.value
      @is_equality ? eval == 0 : eval <= 0
    end
  end
end

struct Number
  def +(x : LinProg::LinearCombination | LinProg::Variable)
    x + self
  end

  def -(x : LinProg::LinearCombination | LinProg::Variable)
    -x + self
  end

  def *(x : LinProg::LinearCombination | LinProg::Variable)
    x*self
  end
end