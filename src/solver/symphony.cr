require "./libSymphony"

module Symphony
  alias Status = LibSymphony::Status
  enum FileFormat
    MPS
    LP
  end
  enum Direction
    Minimize =  1
    Maximize = -1
  end

  record Constraint, min : Float64, max : Float64, integer : Bool = false do
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
      new(-Int64::MIN, -Int64::MAX, true)
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

    def self.from_dense(*, c, a_ub, b_ub, a_eq, b_eq, bounds : (Constraint | Indexable(Constraint) | Nil) = nil)
      raise ArgumentError.new("Columns count of a_ub and a_eq must match") if a_ub.ncolumns != a_eq.ncolumns
      raise ArgumentError.new("Rows count of b_ub and a_ub must match") if a_ub.nrows != b_ub.nrows
      raise ArgumentError.new("Rows count of b_eq and a_eq must match") if a_eq.nrows != b_eq.nrows
      raise ArgumentError.new("Columns count of a_ub and c must match") if a_ub.ncolumns != c.ncolumns
      raise ArgumentError.new("b_ub must have single column") if b_ub.ncolumns != 1
      raise ArgumentError.new("b_eq must have single column") if b_eq.ncolumns != 1
      raise ArgumentError.new("c must have single row") if c.nrows != 1
      if bounds.is_a?(Indexable(Constraint)) && c.nrows != bounds.size
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
        column = i / @nrows
        Float64.new(row < a_ub.nrows ? a_ub[row, column] : a_eq[row, column])
      end
      case bounds
      when Nil
        @collb = Slice(Float64).new(@ncolumns, 0.0)
        @colub = Slice(Float64).new(@ncolumns, Float64::MAX)
        @is_int = Slice(UInt8).new(@ncolumns, 0u8) # false
      when Constraint
        @collb = Slice(Float64).new(@ncolumns, bounds.min)
        @colub = Slice(Float64).new(@ncolumns, bounds.max)
        @is_int = Slice(UInt8).new(@ncolumns, bounds.integer ? 0u8 : 1u8)
      else
        @collb = Slice(Float64).new(@ncolumns) { |i| bounds[i].min.as(Float64) }
        @colub = Slice(Float64).new(@ncolumns) { |i| bounds[i].max.as(Float64) }
        @is_int = Slice(UInt8).new(@ncolumns) { |i| bounds[i].integer ? 0u8 : 1u8 }
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
        a_ub: Linalg::Mat.zeros(0, a_eq.ncolumns),
        b_ub: Linalg::Mat.zeros(0, 1),
        a_eq: a_eq, b_eq: b_eq, bounds: bounds)
    end

    def self.from_dense(*, c, a_ub, b_ub, bounds = nil)
      from_dense(c: c,
        a_eq: Linalg::Mat.zeros(0, a_ub.ncolumns),
        b_eq: Linalg::Mat.zeros(0, 1),
        a_ub: a_ub, b_ub: b_ub, bounds: bounds)
    end
  end

  class Solver
    DEFAULT = new()
    @handle : LibSymphony::Environment?

    private macro call(function, *args)
      st = LibSymphony.{{function}}(@handle.not_nil!, {{*args}})
      raise st.to_s if st.to_i < 0
      st
    end

    def initialize
      @handle = LibSymphony.open_environment
      call(set_user_data, self.as(Void*))
    end

    protected def initialize(*, copy_from)
      @handle = LibSymphony.create_copy_environment(copy_from)
      call(set_user_data, self.as(Void*))
      call(set_int_param, "verbosity", -1)
    end

    def free!
      return unless @handle
      call(close_environment)
      @handle = nil
    end

    def reset
      call(reset_environment)
    end

    def set_defaults
      call(set_defaults)
    end

    def clone
      Solver.new(copy_from: @handle.not_nil!)
    end

    def load(filename : String, format : FileFormat = FileFormat::MPS)
      case format
      when .mps?
        call(read_mps, filename)
      when .lp?
        call read_lp, filename
      end
    end

    def load_gmpl(modelfile : String, datafile : String)
      call read_gmpl, modelfile, datafile
    end

    def save(filename : String, format : FileFormat = FileFormat::MPS)
      case format
      when .mps?
        call write_mps, filename
      when .lp?
        call write_lp, filename
      end
    end

    def finalize
      free!
    end

    # getter problem : Problem?

    def load_explicit(aproblem : Problem)
      raise ArgumentError.new "problem is incorrect" unless aproblem.correct
      # @problem = aproblem
      call(explicit_load_problem, aproblem.ncolumns, aproblem.nrows,
        aproblem.sparse_starts, aproblem.sparse_indices, aproblem.sparse_values,
        aproblem.collb, aproblem.colub, aproblem.is_int,
        aproblem.obj, aproblem.obj2,
        aproblem.rowsen, aproblem.rowrhs, aproblem.rowrng, 1_u8)
    end

    def solve
      call solve
    end

    def status
      call get_status
    end

    def solution_x
      call(get_num_cols, out ncols)
      result = Array(Float64).new(ncols, 0.0)
      call get_col_solution, result
      result
    end

    def solution_f
      call get_obj_val, out result
      result
    end

    def other_solutions
      call(get_num_cols, out ncols)
      call get_sp_size, out nsol
      result = Array({x: Array(Float64), f: Float64}).new(nsol) do |i|
        x = Array(Float64).new(ncols, 0.0)
        call get_sp_solution, i, x, out f
        {x: x, f: f}
      end
    end

    def direction
      call get_obj_sense, out var
      Direction.new(var)
    end

    def direction=(value : Direction)
      call set_obj_sense, value.to_i
    end

    # def find_initial_bounds
    #   call find_initial_bounds
    # end
    #
    #
    # def warm_solve
    #   call warm_solve
    # end
    #
    # def mc_solve
    #   call mc_solve
    # end

  end
end
