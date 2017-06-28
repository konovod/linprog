@[Link("CoinMP")]
lib LibCoinMP
  enum CallResult
    SUCCESS =  0
    FAILED  = -1
  end

  @[Flags]
  enum Method
    DEFAULT = 0x00000000

    PRIMAL  = 0x00000001
    DUAL    = 0x00000002
    NETWORK = 0x00000004
    BARRIER = 0x00000008

    BENDERS = 0x00000100
    DEQ     = 0x00000200
    EV      = 0x00000400
  end

  @[Flags]
  enum Feature
    LP    = 0x00000001
    QP    = 0x00000002
    QCP   = 0x00000004
    NLP   = 0x00000008
    MIP   = 0x00000010
    MIQP  = 0x00000020
    MIQCP = 0x00000040
    MINLP = 0x00000080
    SP    = 0x00010000
  end

  enum ObjSens
    SOLV_OBJSENS_MAX = -1
    SOLV_OBJSENS_MIN =  1
  end

  enum File
    LOG      = 0
    BASIS    = 1
    MIPSTART = 2
    MPS      = 3
    LP       = 4
    BINARY   = 5
    OUTPUT   = 6
    BINOUT   = 7
    IIS      = 8
  end

  enum Check
    COLCOUNT    =  1
    ROWCOUNT    =  2
    RANGECOUNT  =  3
    OBJSENSE    =  4
    ROWTYPE     =  5
    MATBEGIN    =  6
    MATCOUNT    =  7
    MATBEGCNT   =  8
    MATBEGNZ    =  9
    MATINDEX    = 10
    MATINDEXROW = 11
    BOUNDS      = 12
    COLTYPE     = 13
    COLNAMES    = 14
    COLNAMESLEN = 15
    ROWNAMES    = 16
    ROWNAMSLEN  = 17
  end

  alias Hprob = Void*

  alias CoinMsglogCb = (LibC::Char*, Void* -> LibC::Int)
  alias CoinLpiterCb = (LibC::Int, LibC::Double, LibC::Int, LibC::Double, Void* -> LibC::Int)
  alias CoinMipnodeCb = (LibC::Int, LibC::Int, LibC::Double, LibC::Double, LibC::Int, Void* -> LibC::Int)
  alias Msglogcallback = (LibC::Char* -> LibC::Int)
  alias Itercallback = (LibC::Int, LibC::Double, LibC::Int, LibC::Double -> LibC::Int)
  alias Mipnodecallback = (LibC::Int, LibC::Int, LibC::Double, LibC::Double, LibC::Int -> LibC::Int)

  fun init_solver = CoinInitSolver(license_str : LibC::Char*) : LibC::Int
  fun free_solver = CoinFreeSolver : LibC::Int
  fun get_solver_name = CoinGetSolverName : LibC::Char*
  fun get_solver_name_buf = CoinGetSolverNameBuf(solver_name : LibC::Char*, buflen : LibC::Int) : LibC::Int
  fun get_version_str = CoinGetVersionStr : LibC::Char*
  fun get_version_str_buf = CoinGetVersionStrBuf(version_str : LibC::Char*, buflen : LibC::Int) : LibC::Int
  fun get_version = CoinGetVersion : LibC::Double
  fun get_features = CoinGetFeatures : LibC::Int
  fun get_methods = CoinGetMethods : LibC::Int
  fun get_infinity = CoinGetInfinity : LibC::Double
  fun create_problem = CoinCreateProblem(problem_name : LibC::Char*) : Hprob
  fun load_matrix = CoinLoadMatrix(h_prob : Hprob, col_count : LibC::Int, row_count : LibC::Int, nz_count : LibC::Int, range_count : LibC::Int, object_sense : LibC::Int, object_const : LibC::Double, object_coeffs : LibC::Double*, lower_bounds : LibC::Double*, upper_bounds : LibC::Double*, row_type : LibC::Char*, rhs_values : LibC::Double*, range_values : LibC::Double*, matrix_begin : LibC::Int*, matrix_count : LibC::Int*, matrix_index : LibC::Int*, matrix_values : LibC::Double*) : LibC::Int
  fun load_names = CoinLoadNames(h_prob : Hprob, col_names_list : LibC::Char**, row_names_list : LibC::Char**, object_name : LibC::Char*) : LibC::Int
  fun load_names_buf = CoinLoadNamesBuf(h_prob : Hprob, col_names_buf : LibC::Char*, row_names_buf : LibC::Char*, object_name : LibC::Char*) : LibC::Int
  fun load_problem = CoinLoadProblem(h_prob : Hprob, col_count : LibC::Int, row_count : LibC::Int, nz_count : LibC::Int, range_count : LibC::Int, object_sense : LibC::Int, object_const : LibC::Double, object_coeffs : LibC::Double*, lower_bounds : LibC::Double*, upper_bounds : LibC::Double*, row_type : LibC::Char*, rhs_values : LibC::Double*, range_values : LibC::Double*, matrix_begin : LibC::Int*, matrix_count : LibC::Int*, matrix_index : LibC::Int*, matrix_values : LibC::Double*, col_names_list : LibC::Char**, row_names_list : LibC::Char**, object_name : LibC::Char*) : LibC::Int
  fun load_problem_buf = CoinLoadProblemBuf(h_prob : Hprob, col_count : LibC::Int, row_count : LibC::Int, nz_count : LibC::Int, range_count : LibC::Int, object_sense : LibC::Int, object_const : LibC::Double, object_coeffs : LibC::Double*, lower_bounds : LibC::Double*, upper_bounds : LibC::Double*, row_type : LibC::Char*, rhs_values : LibC::Double*, range_values : LibC::Double*, matrix_begin : LibC::Int*, matrix_count : LibC::Int*, matrix_index : LibC::Int*, matrix_values : LibC::Double*, col_names_buf : LibC::Char*, row_names_buf : LibC::Char*, object_name : LibC::Char*) : LibC::Int
  fun load_init_values = CoinLoadInitValues(h_prob : Hprob, init_values : LibC::Double*) : LibC::Int
  fun load_integer = CoinLoadInteger(h_prob : Hprob, column_type : LibC::Char*) : LibC::Int
  fun load_priority = CoinLoadPriority(h_prob : Hprob, prior_count : LibC::Int, prior_index : LibC::Int*, prior_values : LibC::Int*, prior_branch : LibC::Int*) : LibC::Int
  fun load_sos = CoinLoadSos(h_prob : Hprob, sos_count : LibC::Int, sos_nz_count : LibC::Int, sos_type : LibC::Int*, sos_prior : LibC::Int*, sos_begin : LibC::Int*, sos_index : LibC::Int*, sos_ref : LibC::Double*) : LibC::Int
  fun load_semi_cont = CoinLoadSemiCont(h_prob : Hprob, semi_count : LibC::Int, semi_index : LibC::Int*) : LibC::Int
  fun load_quadratic = CoinLoadQuadratic(h_prob : Hprob, quad_begin : LibC::Int*, quad_count : LibC::Int*, quad_index : LibC::Int*, quad_values : LibC::Double*) : LibC::Int
  fun load_nonlinear = CoinLoadNonlinear(h_prob : Hprob, nlp_tree_count : LibC::Int, nlp_line_count : LibC::Int, nlp_begin : LibC::Int*, nlp_oper : LibC::Int*, nlp_arg1 : LibC::Int*, nlp_arg2 : LibC::Int*, nlp_index1 : LibC::Int*, nlp_index2 : LibC::Int*, nlp_value1 : LibC::Double*, nlp_value2 : LibC::Double*) : LibC::Int
  fun unload_problem = CoinUnloadProblem(h_prob : Hprob) : LibC::Int
  fun check_problem = CoinCheckProblem(h_prob : Hprob) : LibC::Int
  fun get_problem_name = CoinGetProblemName(h_prob : Hprob) : LibC::Char*
  fun get_problem_name_buf = CoinGetProblemNameBuf(h_prob : Hprob, problem_name : LibC::Char*, buflen : LibC::Int) : LibC::Int
  fun get_col_count = CoinGetColCount(h_prob : Hprob) : LibC::Int
  fun get_row_count = CoinGetRowCount(h_prob : Hprob) : LibC::Int
  fun get_col_name = CoinGetColName(h_prob : Hprob, col : LibC::Int) : LibC::Char*
  fun get_col_name_buf = CoinGetColNameBuf(h_prob : Hprob, col : LibC::Int, col_name : LibC::Char*, buflen : LibC::Int) : LibC::Int
  fun get_row_name = CoinGetRowName(h_prob : Hprob, row : LibC::Int) : LibC::Char*
  fun get_row_name_buf = CoinGetRowNameBuf(h_prob : Hprob, row : LibC::Int, row_name : LibC::Char*, buflen : LibC::Int) : LibC::Int
  fun register_msg_log_callback = CoinRegisterMsgLogCallback(h_prob : Hprob, msg_log_cb : CoinMsglogCb, user_param : Void*) : LibC::Int
  fun register_lp_iter_callback = CoinRegisterLPIterCallback(h_prob : Hprob, lp_iter_cb : CoinLpiterCb, user_param : Void*) : LibC::Int
  fun register_mip_node_callback = CoinRegisterMipNodeCallback(h_prob : Hprob, mip_node_cb : CoinMipnodeCb, user_param : Void*) : LibC::Int
  fun set_msg_log_callback = CoinSetMsgLogCallback(h_prob : Hprob, msg_log_callback : Msglogcallback) : LibC::Int
  fun set_iter_callback = CoinSetIterCallback(h_prob : Hprob, iter_callback : Itercallback) : LibC::Int
  fun set_mip_node_callback = CoinSetMipNodeCallback(h_prob : Hprob, mip_node_callback : Mipnodecallback) : LibC::Int
  fun optimize_problem = CoinOptimizeProblem(h_prob : Hprob, method : LibC::Int) : LibC::Int
  fun get_solution_status = CoinGetSolutionStatus(h_prob : Hprob) : LibC::Int
  fun get_solution_text = CoinGetSolutionText(h_prob : Hprob) : LibC::Char*
  fun get_solution_text_buf = CoinGetSolutionTextBuf(h_prob : Hprob, solution_text : LibC::Char*, buflen : LibC::Int) : LibC::Int
  fun get_object_value = CoinGetObjectValue(h_prob : Hprob) : LibC::Double
  fun get_mip_best_bound = CoinGetMipBestBound(h_prob : Hprob) : LibC::Double
  fun get_iter_count = CoinGetIterCount(h_prob : Hprob) : LibC::Int
  fun get_mip_node_count = CoinGetMipNodeCount(h_prob : Hprob) : LibC::Int
  fun get_solution_values = CoinGetSolutionValues(h_prob : Hprob, activity : LibC::Double*, reduced_cost : LibC::Double*, slack_values : LibC::Double*, shadow_price : LibC::Double*) : LibC::Int
  fun get_solution_ranges = CoinGetSolutionRanges(h_prob : Hprob, obj_lo_range : LibC::Double*, obj_up_range : LibC::Double*, rhs_lo_range : LibC::Double*, rhs_up_range : LibC::Double*) : LibC::Int
  fun get_solution_basis = CoinGetSolutionBasis(h_prob : Hprob, col_status : LibC::Int*, row_status : LibC::Int*) : LibC::Int
  fun read_file = CoinReadFile(h_prob : Hprob, file_type : LibC::Int, read_filename : LibC::Char*) : LibC::Int
  fun write_file = CoinWriteFile(h_prob : Hprob, file_type : LibC::Int, write_filename : LibC::Char*) : LibC::Int
  fun open_log_file = CoinOpenLogFile(h_prob : Hprob, log_filename : LibC::Char*) : LibC::Int
  fun close_log_file = CoinCloseLogFile(h_prob : Hprob) : LibC::Int
  fun get_option_count = CoinGetOptionCount(h_prob : Hprob) : LibC::Int
  fun locate_option_id = CoinLocateOptionID(h_prob : Hprob, option_id : LibC::Int) : LibC::Int
  fun locate_option_name = CoinLocateOptionName(h_prob : Hprob, option_name : LibC::Char*) : LibC::Int
  fun get_option_id = CoinGetOptionID(h_prob : Hprob, option_nr : LibC::Int) : LibC::Int
  fun get_option_info = CoinGetOptionInfo(h_prob : Hprob, option_nr : LibC::Int, option_id : LibC::Int*, group_type : LibC::Int*, option_type : LibC::Int*) : LibC::Int
  fun get_int_option_min_max = CoinGetIntOptionMinMax(h_prob : Hprob, option_nr : LibC::Int, min_value : LibC::Int*, max_value : LibC::Int*) : LibC::Int
  fun get_real_option_min_max = CoinGetRealOptionMinMax(h_prob : Hprob, option_nr : LibC::Int, min_value : LibC::Double*, max_value : LibC::Double*) : LibC::Int
  fun get_option_names_buf = CoinGetOptionNamesBuf(h_prob : Hprob, option_nr : LibC::Int, option_name : LibC::Char*, short_name : LibC::Char*, buflen : LibC::Int) : LibC::Int
  fun get_option_group = CoinGetOptionGroup(h_prob : Hprob, option_id : LibC::Int) : LibC::Int
  fun get_option_type = CoinGetOptionType(h_prob : Hprob, option_id : LibC::Int) : LibC::Int
  fun get_int_option_default_value = CoinGetIntOptionDefaultValue(h_prob : Hprob, option_id : LibC::Int) : LibC::Int
  fun get_int_option_min_value = CoinGetIntOptionMinValue(h_prob : Hprob, option_id : LibC::Int) : LibC::Int
  fun get_int_option_max_value = CoinGetIntOptionMaxValue(h_prob : Hprob, option_id : LibC::Int) : LibC::Int
  fun get_real_option_default_value = CoinGetRealOptionDefaultValue(h_prob : Hprob, option_id : LibC::Int) : LibC::Double
  fun get_real_option_min_value = CoinGetRealOptionMinValue(h_prob : Hprob, option_id : LibC::Int) : LibC::Double
  fun get_real_option_max_value = CoinGetRealOptionMaxValue(h_prob : Hprob, option_id : LibC::Int) : LibC::Double
  fun get_option_name = CoinGetOptionName(h_prob : Hprob, option_id : LibC::Int) : LibC::Char*
  fun get_option_name_buf = CoinGetOptionNameBuf(h_prob : Hprob, option_id : LibC::Int, option_name : LibC::Char*, buflen : LibC::Int) : LibC::Int
  fun get_option_short_name = CoinGetOptionShortName(h_prob : Hprob, option_id : LibC::Int) : LibC::Char*
  fun get_option_short_name_buf = CoinGetOptionShortNameBuf(h_prob : Hprob, option_id : LibC::Int, short_name : LibC::Char*, buflen : LibC::Int) : LibC::Int
  fun get_option_changed = CoinGetOptionChanged(h_prob : Hprob, option_id : LibC::Int) : LibC::Int
  fun get_int_option = CoinGetIntOption(h_prob : Hprob, option_id : LibC::Int) : LibC::Int
  fun set_int_option = CoinSetIntOption(h_prob : Hprob, option_id : LibC::Int, int_value : LibC::Int) : LibC::Int
  fun get_real_option = CoinGetRealOption(h_prob : Hprob, option_id : LibC::Int) : LibC::Double
  fun set_real_option = CoinSetRealOption(h_prob : Hprob, option_id : LibC::Int, real_value : LibC::Double) : LibC::Int
  fun get_string_option = CoinGetStringOption(h_prob : Hprob, option_id : LibC::Int) : LibC::Char*
  fun get_string_option_buf = CoinGetStringOptionBuf(h_prob : Hprob, option_id : LibC::Int, string_value : LibC::Char*, buflen : LibC::Int) : LibC::Int
  fun set_string_option = CoinSetStringOption(h_prob : Hprob, option_id : LibC::Int, string_value : LibC::Char*) : LibC::Int
end
