module GLPK
  enum Driver
    Simplex
    Exact
    Interior
    MIP
  end

  def self.solve(*, driver : Driver? = nil, **named_args)
    solve(LinProg::Problem.from_dense(**named_args), driver)
  end

  def self.solve(problem : LinProg::Problem, driver : Driver? = nil)
    # select default driver
    unless driver
      driver = (problem.is_int.any? { |x| x != 0 }) ? Driver::MIP : Driver::Simplex
    end

    # create problem
    handle = LibGLPK.create_prob
    LibGLPK.add_rows handle, problem.nrows
    LibGLPK.add_cols handle, problem.ncolumns
    # load bounds
    problem.ncolumns.times do |i|
      has_lower = problem.collb[i] > Float64::MIN
      has_upper = problem.colub[i] < Float64::MAX
      if has_upper && has_lower
        LibGLPK.set_col_bnds(handle, i + 1, LibGLPK::VariableType::Double, problem.collb[i], problem.colub[i])
      elsif has_upper
        LibGLPK.set_col_bnds(handle, i + 1, LibGLPK::VariableType::Upper, problem.colub[i], 0.0)
      elsif has_lower
        LibGLPK.set_col_bnds(handle, i + 1, LibGLPK::VariableType::Lower, problem.collb[i], 0.0)
      else
        LibGLPK.set_col_bnds(handle, i + 1, LibGLPK::VariableType::Free, 0.0, 0.0)
      end
      LibGLPK.set_col_kind(handle, i + 1, problem.is_int[i] != 0 ? LibGLPK::VariableKind::Integer : LibGLPK::VariableKind::Continuous)
    end
    # load constraint types
    problem.nrows.times do |i|
      if problem.rowsen[i] == 'E'.ord
        LibGLPK.set_row_bnds(handle, i + 1, LibGLPK::VariableType::Fixed, problem.rowrhs[i], 0.0)
      else
        LibGLPK.set_row_bnds(handle, i + 1, LibGLPK::VariableType::Upper, 0.0, problem.rowrhs[i])
      end
    end
    # load constraints matrix
    offset_indices = Slice(Int32).new(problem.sparse_indices.size + 1) { |i| i == 0 ? 0 : problem.sparse_indices[i - 1] + 1 }
    problem.ncolumns.times do |i|
      LibGLPK.set_mat_col(handle, i + 1,
        problem.sparse_starts[i + 1] - problem.sparse_starts[i],         # length
        offset_indices + problem.sparse_starts[i],                       # indices
        problem.sparse_values.to_unsafe + (problem.sparse_starts[i] - 1) # values
      )
    end
    # load objective
    LibGLPK.set_obj_dir(handle, LibGLPK::OptimizationDirection::MIN)
    problem.obj.each_with_index { |v, i| LibGLPK.set_obj_coef(handle, i + 1, v) }

    # solve
    code = case driver
           in .simplex?
             LibGLPK.cpx_basis(handle)
             LibGLPK.init_smcp(out params1)
             params1.presolve = 1
             LibGLPK.simplex(handle, pointerof(params1))
           in .exact?
             LibGLPK.cpx_basis(handle)
             LibGLPK.init_smcp(out params2)
             params2.presolve = 1
             LibGLPK.simplex(handle, pointerof(params2))
             LibGLPK.exact(handle, pointerof(params2))
           in .interior?
             LibGLPK.init_iptcp(out params3)
             LibGLPK.interior(handle, pointerof(params3))
           in .mip?
             LibGLPK.cpx_basis(handle)
             LibGLPK.init_smcp(out params41)
             params41.presolve = 1
             LibGLPK.simplex(handle, pointerof(params41))
             LibGLPK.init_iocp(out params4)
             LibGLPK.intopt(handle, pointerof(params4))
           end
    unless code.success?
      raise LinProg::Error.new(code.to_s)
    end
    status = case driver
             in .simplex?, .exact?
               LibGLPK.get_status(handle)
             in .interior?
               LibGLPK.ipt_status(handle)
             in .mip?
               LibGLPK.mip_status(handle)
             end
    unless status.optimal?
      raise LinProg::Error.new(status.to_s)
    end
    # get  results
    x = Array(Float64).new(problem.ncolumns, 0.0)
    f = 0.0
    case driver
    in .simplex?, .exact?
      f = LibGLPK.get_obj_val(handle)
      problem.ncolumns.times { |i| x[i] = LibGLPK.get_col_prim(handle, i + 1) }
    in .interior?
      f = LibGLPK.ipt_obj_val(handle)
      problem.ncolumns.times { |i| x[i] = LibGLPK.ipt_col_prim(handle, i + 1) }
    in .mip?
      f = LibGLPK.mip_obj_val(handle)
      problem.ncolumns.times { |i| x[i] = LibGLPK.mip_col_val(handle, i + 1) }
    end
    # free solver
    LibGLPK.delete_prob handle
    {x, f}
  end
end
