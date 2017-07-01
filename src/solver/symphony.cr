module Symphony
  enum FileFormat
    MPS
    LP
  end

  class Problem
    getter nrows : Int32
    getter ncolumns : Int32
    getter sparse_starts
    getter sparse_indices
    getter sparse_values
    getter collb
    getter colub
    getter is_int
    getter obj
    getter obj2
    getter rowsen
    getter rowrhs
    getter rowrng

    def initialize(c, a_ub, b_ub, a_eq, b_eq)
      raise ArgumentError.new("Columns count of a_ub and a_eq must match") if a_ub.ncolumns != a_eq.ncolumns
      raise ArgumentError.new("Rows count of b_ub and a_ub must match") if a_ub.nrows != b_ub.nrows
      raise ArgumentError.new("Rows count of b_eq and a_eq must match") if a_eq.nrows != b_eq.nrows
      raise ArgumentError.new("Columns count of a_ub and c must match") if a_ub.ncolumns != c.ncolumns
      raise ArgumentError.new("b_un must have single column") if b_un.ncolumns != 1
      raise ArgumentError.new("b_eq must have single column") if b_eq.ncolumns != 1
      raise ArgumentError.new("c must have single column") if c.ncolumns != 1
      @nrows = a_ub.nrows + a_eq.nrows
      @ncolumns = a_un.ncolumns
      @sparse_starts = Slice(Int32).new(@ncolumns + 1, 0) { |i| i*@nrows }
      @sparse_indices = Slice(Int32).new(@nrows*@ncolumns) { |i| i % @nrows }
      @sparse_values = Slice(Double).new(@nrows*@ncolumns) do |i|
        row = i % @nrows
        column = i / @nrows
        Float64.new(row < a_ub.nrows ? a_ub[row, column] : a_eq[row, column])
      end
      @collb = Slice(Double).new(@ncolumns, 0.0)
      @colub = Slice(Double).new(@ncolumns, Math::Infinity)
      @is_int = Slice(UInt8).new(@ncolumns, 0)
      @obj = Slice(Double).new(@ncolumns) { |i| Float64.new(c[i, 0]) }
      @obj2 = Slice(Double).new(@ncolumns, 0.0)
      @rowsen = Slice(UInt8).new(@nrows) { |i| i < a_ub.nrows ? 'L'.ord : 'E'.ord }
      @rowrhs = Slice(Double).new(@nrows) { |i| Float64.new(i < a_ub.nrows ? b_ub[i, 0] : b_eq[i, 0]) }
      @rowrng = Slice(Double).new(@nrows, 0.0)
    end
  end

  class Solver
    @handle : LibSymphony::Environment

    private macro call(function, *args)
      st = LibSymphony.{{function}}(@handle, {{*args}})
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
    end

    def free!
      call(close_environment)
    end

    def reset
      call(reset_environment)
    end

    def set_defaults
      call(set_defaults)
    end

    def clone
      Solver.new(copy_from: @handle)
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
      call read_gmpl(modelfile, datafile)
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

    def load_explicit(problem : Problem)
      # call load_explicit,
    end

    # def find_initial_bounds
    #   call find_initial_bounds
    # end
    #
    def solve
      call solve
    end

    #
    # def warm_solve
    #   call warm_solve
    # end
    #
    # def mc_solve
    #   call mc_solve
    # end

    def status
      call get_status
    end
  end
end
