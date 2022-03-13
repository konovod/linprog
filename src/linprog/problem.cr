module LinProg
  class Error < Exception
  end

  enum Direction
    Minimize =  1
    Maximize = -1
  end

  record Bound, min : Float64, max : Float64, integer : Bool = false do
    def self.none
      new(Float64::MIN, Float64::MAX)
    end

    def self.positive
      new(0.0, Float64::MAX)
    end

    def self.negative
      new(Float64::MIN, 0.0)
    end

    def self.integer
      new(Float64::MIN, Float64::MAX, true)
    end

    def self.binary
      new(0.0, 1.0, true)
    end
  end

  class Problem
    getter nrows : Int32
    getter ncolumns : Int32
    getter sparse_starts
    getter sparse_indices
    getter sparse_values
    getter collb : Slice(Float64)
    getter colub : Slice(Float64)
    getter is_int : Slice(UInt8)
    getter obj
    getter obj2
    getter rowsen
    getter rowrhs
    getter rowrng
    getter correct = false

    def self.from_dense(*, c, a_ub, b_ub, a_eq, b_eq, bounds : (Bound | Indexable(Bound) | Nil) = nil)
      raise ArgumentError.new("Columns count of a_ub and a_eq must match") if a_ub.ncolumns != a_eq.ncolumns
      raise ArgumentError.new("Rows count of b_ub and a_ub must match") if a_ub.nrows != b_ub.nrows
      raise ArgumentError.new("Rows count of b_eq and a_eq must match") if a_eq.nrows != b_eq.nrows
      raise ArgumentError.new("Columns count of a_ub and c must match") if a_ub.ncolumns != c.ncolumns
      raise ArgumentError.new("b_ub must have single column") if b_ub.ncolumns != 1
      raise ArgumentError.new("b_eq must have single column") if b_eq.ncolumns != 1
      raise ArgumentError.new("c must have single row") if c.nrows != 1
      if bounds.is_a?(Indexable(Bound)) && c.ncolumns != bounds.size
        raise ArgumentError.new("bounds.size must match columns of c")
      end
      new(c: c, a_ub: a_ub, b_ub: b_ub, a_eq: a_eq, b_eq: b_eq, bounds: bounds)
    end

    protected def initialize(*, c, a_ub, b_ub, a_eq, b_eq, bounds)
      @nrows = a_ub.nrows + a_eq.nrows
      @ncolumns = a_ub.ncolumns
      @sparse_starts = Slice(Int32).new(@ncolumns + 1) { |i| i*@nrows }
      @sparse_indices = Slice(Int32).new(@nrows*@ncolumns) { |i| i % @nrows }
      @sparse_values = Slice(Float64).new(@nrows*@ncolumns) do |i|
        row = i % @nrows
        column = i // @nrows
        Float64.new(row < a_ub.nrows ? a_ub[row, column] : a_eq[row, column])
      end
      case bounds
      when Nil
        @collb = Slice(Float64).new(@ncolumns, Float64::MIN)
        @colub = Slice(Float64).new(@ncolumns, Float64::MAX)
        @is_int = Slice(UInt8).new(@ncolumns, 0u8) # false
      when Bound
        @collb = Slice(Float64).new(@ncolumns, bounds.min)
        @colub = Slice(Float64).new(@ncolumns, bounds.max)
        @is_int = Slice(UInt8).new(@ncolumns, bounds.integer ? 1u8 : 0u8)
      else
        @collb = Slice(Float64).new(@ncolumns) { |i| bounds[i].min.as(Float64) }
        @colub = Slice(Float64).new(@ncolumns) { |i| bounds[i].max.as(Float64) }
        @is_int = Slice(UInt8).new(@ncolumns) { |i| bounds[i].integer ? 1u8 : 0u8 }
      end
      @obj = Slice(Float64).new(@ncolumns) { |i| Float64.new(c[0, i]) }
      @obj2 = Slice(Float64).new(@ncolumns, 0.0)
      @rowsen = Slice(UInt8).new(@nrows) { |i| UInt8.new(i < a_ub.nrows ? 'L'.ord : 'E'.ord) }
      @rowrhs = Slice(Float64).new(@nrows) { |i| Float64.new(i < a_ub.nrows ? b_ub[i, 0] : b_eq[i, 0]) }
      @rowrng = Slice(Float64).new(@nrows, 0.0)
      @correct = true
    end

    def self.from_dense(*, c, a_eq, b_eq, bounds = nil)
      from_dense(c: c,
        a_ub: LA::Mat.zeros(0, a_eq.ncolumns),
        b_ub: LA::Mat.zeros(0, 1),
        a_eq: a_eq, b_eq: b_eq, bounds: bounds)
    end

    def self.from_dense(*, c, a_ub, b_ub, bounds = nil)
      from_dense(c: c,
        a_eq: LA::Mat.zeros(0, a_ub.ncolumns),
        b_eq: LA::Mat.zeros(0, 1),
        a_ub: a_ub, b_ub: b_ub, bounds: bounds)
    end

    def initialize(*, vars, constraints, id_to_index, obj)
      @nrows = constraints.size
      @ncolumns = id_to_index.size
      nvalues = constraints.sum(&.combination.k.size)
      @sparse_starts = Slice(Int32).new(@ncolumns + 1, 0)
      @sparse_indices = Slice(Int32).new(nvalues, 0)
      @sparse_values = Slice(Float64).new(nvalues, 0.0)
      @obj = Slice(Float64).new(@ncolumns, 0.0)
      @obj2 = Slice(Float64).new(@ncolumns, 0.0)
      @collb = Slice(Float64).new(@ncolumns, 0.0)
      @colub = Slice(Float64).new(@ncolumns, 0.0)
      @is_int = Slice(UInt8).new(@ncolumns, 0u8)

      pos = 0
      # we assume id_to_index is sorted
      id_to_index.each do |id, index|
        var = vars[id]
        @sparse_starts[index] = pos
        # fill each column
        constraints.each_with_index do |c, row|
          next unless c.combination.k.has_key?(var)
          @sparse_indices[pos] = row
          @sparse_values[pos] = c.combination.k[var]
          pos += 1
        end
        bound = var.bound
        @collb[index] = bound.min
        @colub[index] = bound.max
        @is_int[index] = bound.integer ? 1u8 : 0u8
        @obj[index] = obj.k[var]? || 0.0
      end
      @sparse_starts[@ncolumns] = pos

      @rowsen = Slice(UInt8).new(@nrows) { |i| UInt8.new(constraints[i].is_equality ? 'E'.ord : 'L'.ord) }
      @rowrhs = Slice(Float64).new(@nrows) { |i| -constraints[i].combination.c }
      @rowrng = Slice(Float64).new(@nrows, 0.0)
      @correct = true
    end
  end

  class SymbolProblem
    getter vars = [] of Variable
    getter constraints = [] of Constraint
    property objective : LinearCombination?

    def initialize
    end

    def create_var(*args, **named_args)
      Variable.new(self, UInt64.new(vars.size), *args, **named_args).tap { |v| @vars << v }
    end

    def st(c : Constraint)
      @constraints << c
    end

    def minimize(objective)
      @objective = objective
    end

    def maximize(objective)
      @objective = -objective
    end

    @used_indices = {} of VarID => Int32
    @vars_used = [] of Bool
    @var_values = [] of Float64

    def var_value(var)
      if index = @used_indices[var.id]
        @var_values[index]
      else
        var.bound.min
      end
    end

    def solve
      # sanity checks
      raise "no objective given, use #minimize or #maximize" unless obj = @objective
      @constraints.each do |con|
        raise "empty constraint: #{con}" if con.combination.k.size == 0
        raise "wrong owner of var in constraint con" if con.combination.k.keys.any? { |v| v.owner != self }
      end
      # first generate used indices map from constraints and objective
      @vars_used = Array(Bool).new(vars.size, false)
      @constraints.each do |c|
        c.combination.k.keys.each do |v|
          @vars_used[v.id] = true
        end
      end
      @used_indices.clear
      n = 0
      @vars_used.each_with_index do |used, i|
        if used
          @used_indices[VarID.new(i)] = n
          n += 1
        end
      end
      # create problem
      problem = Problem.new(vars: @vars, constraints: @constraints, id_to_index: @used_indices, obj: obj)
      # solve
      solver = Symphony::Solver.new
      solver.load_explicit(problem)
      solver.solve
      st = solver.status
      unless st == Symphony::Status::OPTIMAL_SOLUTION_FOUND
        solver.free!
        raise Error.new(st.to_s)
      end
      # save solution
      @var_values = solver.solution_x.dup
      solver.free!
    end
  end
end
