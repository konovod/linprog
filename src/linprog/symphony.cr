require "./libSymphony"
require "./problem"

module LinProg
  def self.solve(*args, **named_args)
    solver = Symphony::Solver.new
    solver.load_explicit(Problem.from_dense(**named_args))
    solver.solve
    st = solver.status
    unless st == Symphony::Status::OPTIMAL_SOLUTION_FOUND
      solver.free!
      raise Error.new(st.to_s)
    end
    x, f = {solver.solution_x, solver.solution_f}
    solver.free!
    {x, f}
  end
end

module Symphony
  alias Status = LibSymphony::Status
  enum FileFormat
    MPS
    LP
  end

  class Solver
    @handle : LibSymphony::Environment?

    private macro call(function, *args)
      st = LibSymphony.{{function}}(@handle.not_nil!, {{*args}})
      raise LinProg::Error.new(st.to_s) if st.to_i < 0
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

    def load_explicit(aproblem : LinProg::Problem)
      raise ArgumentError.new "problem is incorrect" unless aproblem.correct
      call(explicit_load_problem, aproblem.ncolumns, aproblem.nrows,
        aproblem.sparse_starts, aproblem.sparse_indices, aproblem.sparse_values,
        aproblem.collb, aproblem.colub, aproblem.is_int,
        aproblem.obj, aproblem.obj2,
        aproblem.rowsen, aproblem.rowrhs, aproblem.rowrng, 1_u8)
    end

    def solve
      call(set_int_param, "verbosity", -2)
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
      LinProg::Direction.new(var)
    end

    def direction=(value : LinProg::Direction)
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
