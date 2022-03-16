{% if flag?(:windows) %}
  @[Link("glpk_5_0")]
{% else %}
  @[Link("glpk")]
{% end %}
lib LibGLPK
  enum OptimizationDirection
    MIN = 1
    MAX = 2
  end

  enum VariableKind
    Continuous = 1
    Integer    = 2
    Binary     = 3
  end

  enum VariableType
    Free   = 1
    Lower  = 2
    Upper  = 3
    Double = 4
    Fixed  = 5
  end

  enum VariableStatus
    Basic      = 1
    LowerBound = 2
    UpperBound = 3
    Free       = 4
    Fixed      = 5
  end

  @[Flags]
  enum ScalingOptions
    GeometricMean  = 0x01
    Equilibration  = 0x10
    PowerOfTwo     = 0x20
    SkipWellScaled = 0x40
    Auto           = 0x80
  end

  enum SolutionIndicator
    Basic = 1
    IPT   = 2
    MIP   = 3
  end

  enum SolutionStatus
    Undefined  = 1
    Feasible   = 2
    Infeasible = 3
    NoFeasible = 4
    Optimal    = 5
    Unbounded  = 6
  end

  type Prob = Void*
  type Tree = Void*
  type Prep = Void*
  type Tran = Void*
  fun create_prob = glp_create_prob : Prob
  fun set_prob_name = glp_set_prob_name(p : Prob, name : LibC::Char*)
  fun set_obj_name = glp_set_obj_name(p : Prob, name : LibC::Char*)
  fun set_obj_dir = glp_set_obj_dir(p : Prob, dir : LibC::Int)
  fun add_rows = glp_add_rows(p : Prob, nrs : LibC::Int) : LibC::Int
  fun add_cols = glp_add_cols(p : Prob, ncs : LibC::Int) : LibC::Int
  fun set_row_name = glp_set_row_name(p : Prob, i : LibC::Int, name : LibC::Char*)
  fun set_col_name = glp_set_col_name(p : Prob, j : LibC::Int, name : LibC::Char*)
  fun set_row_bnds = glp_set_row_bnds(p : Prob, i : LibC::Int, type : LibC::Int, lb : LibC::Double, ub : LibC::Double)
  fun set_col_bnds = glp_set_col_bnds(p : Prob, j : LibC::Int, type : LibC::Int, lb : LibC::Double, ub : LibC::Double)
  fun set_obj_coef = glp_set_obj_coef(p : Prob, j : LibC::Int, coef : LibC::Double)
  fun set_mat_row = glp_set_mat_row(p : Prob, i : LibC::Int, len : LibC::Int, ind : LibC::Int*, val : LibC::Double*)
  fun set_mat_col = glp_set_mat_col(p : Prob, j : LibC::Int, len : LibC::Int, ind : LibC::Int*, val : LibC::Double*)
  fun load_matrix = glp_load_matrix(p : Prob, ne : LibC::Int, ia : LibC::Int*, ja : LibC::Int*, ar : LibC::Double*)
  fun check_dup = glp_check_dup(m : LibC::Int, n : LibC::Int, ne : LibC::Int, ia : LibC::Int*, ja : LibC::Int*) : LibC::Int
  fun sort_matrix = glp_sort_matrix(p : Prob)
  fun del_rows = glp_del_rows(p : Prob, nrs : LibC::Int, num : LibC::Int*)
  fun del_cols = glp_del_cols(p : Prob, ncs : LibC::Int, num : LibC::Int*)
  fun copy_prob = glp_copy_prob(dest : Prob, prob : Prob, names : LibC::Int)
  fun erase_prob = glp_erase_prob(p : Prob)
  fun delete_prob = glp_delete_prob(p : Prob)
  fun get_prob_name = glp_get_prob_name(p : Prob) : LibC::Char*
  fun get_obj_name = glp_get_obj_name(p : Prob) : LibC::Char*
  fun get_obj_dir = glp_get_obj_dir(p : Prob) : LibC::Int
  fun get_num_rows = glp_get_num_rows(p : Prob) : LibC::Int
  fun get_num_cols = glp_get_num_cols(p : Prob) : LibC::Int
  fun get_row_name = glp_get_row_name(p : Prob, i : LibC::Int) : LibC::Char*
  fun get_col_name = glp_get_col_name(p : Prob, j : LibC::Int) : LibC::Char*
  fun get_row_type = glp_get_row_type(p : Prob, i : LibC::Int) : LibC::Int
  fun get_row_lb = glp_get_row_lb(p : Prob, i : LibC::Int) : LibC::Double
  fun get_row_ub = glp_get_row_ub(p : Prob, i : LibC::Int) : LibC::Double
  fun get_col_type = glp_get_col_type(p : Prob, j : LibC::Int) : LibC::Int
  fun get_col_lb = glp_get_col_lb(p : Prob, j : LibC::Int) : LibC::Double
  fun get_col_ub = glp_get_col_ub(p : Prob, j : LibC::Int) : LibC::Double
  fun get_obj_coef = glp_get_obj_coef(p : Prob, j : LibC::Int) : LibC::Double
  fun get_num_nz = glp_get_num_nz(p : Prob) : LibC::Int
  fun get_mat_row = glp_get_mat_row(p : Prob, i : LibC::Int, ind : LibC::Int*, val : LibC::Double*) : LibC::Int
  fun get_mat_col = glp_get_mat_col(p : Prob, j : LibC::Int, ind : LibC::Int*, val : LibC::Double*) : LibC::Int
  fun create_index = glp_create_index(p : Prob)
  fun find_row = glp_find_row(p : Prob, name : LibC::Char*) : LibC::Int
  fun find_col = glp_find_col(p : Prob, name : LibC::Char*) : LibC::Int
  fun delete_index = glp_delete_index(p : Prob)
  fun set_rii = glp_set_rii(p : Prob, i : LibC::Int, rii : LibC::Double)
  fun set_sjj = glp_set_sjj(p : Prob, j : LibC::Int, sjj : LibC::Double)
  fun get_rii = glp_get_rii(p : Prob, i : LibC::Int) : LibC::Double
  fun get_sjj = glp_get_sjj(p : Prob, j : LibC::Int) : LibC::Double
  fun scale_prob = glp_scale_prob(p : Prob, flags : LibC::Int)
  fun unscale_prob = glp_unscale_prob(p : Prob)
  fun set_row_stat = glp_set_row_stat(p : Prob, i : LibC::Int, stat : LibC::Int)
  fun set_col_stat = glp_set_col_stat(p : Prob, j : LibC::Int, stat : LibC::Int)
  fun std_basis = glp_std_basis(p : Prob)
  fun adv_basis = glp_adv_basis(p : Prob, flags : LibC::Int)
  fun cpx_basis = glp_cpx_basis(p : Prob)
  fun simplex = glp_simplex(p : Prob, parm : Smcp*) : LibC::Int

  struct Smcp
    msg_lev : LibC::Int
    meth : LibC::Int
    pricing : LibC::Int
    r_test : LibC::Int
    tol_bnd : LibC::Double
    tol_dj : LibC::Double
    tol_piv : LibC::Double
    obj_ll : LibC::Double
    obj_ul : LibC::Double
    it_lim : LibC::Int
    tm_lim : LibC::Int
    out_frq : LibC::Int
    out_dly : LibC::Int
    presolve : LibC::Int
    excl : LibC::Int
    shift : LibC::Int
    aorn : LibC::Int
    foo_bar : LibC::Double[33]
  end

  fun exact = glp_exact(p : Prob, parm : Smcp*) : LibC::Int
  fun init_smcp = glp_init_smcp(parm : Smcp*)
  fun get_status = glp_get_status(p : Prob) : LibC::Int
  fun get_prim_stat = glp_get_prim_stat(p : Prob) : LibC::Int
  fun get_dual_stat = glp_get_dual_stat(p : Prob) : LibC::Int
  fun get_obj_val = glp_get_obj_val(p : Prob) : LibC::Double
  fun get_row_stat = glp_get_row_stat(p : Prob, i : LibC::Int) : LibC::Int
  fun get_row_prim = glp_get_row_prim(p : Prob, i : LibC::Int) : LibC::Double
  fun get_row_dual = glp_get_row_dual(p : Prob, i : LibC::Int) : LibC::Double
  fun get_col_stat = glp_get_col_stat(p : Prob, j : LibC::Int) : LibC::Int
  fun get_col_prim = glp_get_col_prim(p : Prob, j : LibC::Int) : LibC::Double
  fun get_col_dual = glp_get_col_dual(p : Prob, j : LibC::Int) : LibC::Double
  fun get_unbnd_ray = glp_get_unbnd_ray(p : Prob) : LibC::Int
  fun get_it_cnt = glp_get_it_cnt(p : Prob) : LibC::Int
  fun set_it_cnt = glp_set_it_cnt(p : Prob, it_cnt : LibC::Int)
  fun interior = glp_interior(p : Prob, parm : Iptcp*) : LibC::Int

  struct Iptcp
    msg_lev : LibC::Int
    ord_alg : LibC::Int
    foo_bar : LibC::Double[48]
  end

  fun init_iptcp = glp_init_iptcp(parm : Iptcp*)
  fun ipt_status = glp_ipt_status(p : Prob) : LibC::Int
  fun ipt_obj_val = glp_ipt_obj_val(p : Prob) : LibC::Double
  fun ipt_row_prim = glp_ipt_row_prim(p : Prob, i : LibC::Int) : LibC::Double
  fun ipt_row_dual = glp_ipt_row_dual(p : Prob, i : LibC::Int) : LibC::Double
  fun ipt_col_prim = glp_ipt_col_prim(p : Prob, j : LibC::Int) : LibC::Double
  fun ipt_col_dual = glp_ipt_col_dual(p : Prob, j : LibC::Int) : LibC::Double
  fun set_col_kind = glp_set_col_kind(p : Prob, j : LibC::Int, kind : LibC::Int)
  fun get_col_kind = glp_get_col_kind(p : Prob, j : LibC::Int) : LibC::Int
  fun get_num_int = glp_get_num_int(p : Prob) : LibC::Int
  fun get_num_bin = glp_get_num_bin(p : Prob) : LibC::Int
  fun intopt = glp_intopt(p : Prob, parm : Iocp*) : LibC::Int

  struct Iocp
    msg_lev : LibC::Int
    br_tech : LibC::Int
    bt_tech : LibC::Int
    tol_int : LibC::Double
    tol_obj : LibC::Double
    tm_lim : LibC::Int
    out_frq : LibC::Int
    out_dly : LibC::Int
    cb_func : (Tree, Void* -> Void)
    cb_info : Void*
    cb_size : LibC::Int
    pp_tech : LibC::Int
    mip_gap : LibC::Double
    mir_cuts : LibC::Int
    gmi_cuts : LibC::Int
    cov_cuts : LibC::Int
    clq_cuts : LibC::Int
    presolve : LibC::Int
    binarize : LibC::Int
    fp_heur : LibC::Int
    ps_heur : LibC::Int
    ps_tm_lim : LibC::Int
    sr_heur : LibC::Int
    use_sol : LibC::Int
    save_sol : LibC::Char*
    alien : LibC::Int
    flip : LibC::Int
    foo_bar : LibC::Double[23]
  end

  fun init_iocp = glp_init_iocp(parm : Iocp*)
  fun mip_status = glp_mip_status(p : Prob) : LibC::Int
  fun mip_obj_val = glp_mip_obj_val(p : Prob) : LibC::Double
  fun mip_row_val = glp_mip_row_val(p : Prob, i : LibC::Int) : LibC::Double
  fun mip_col_val = glp_mip_col_val(p : Prob, j : LibC::Int) : LibC::Double
  fun check_kkt = glp_check_kkt(p : Prob, sol : LibC::Int, cond : LibC::Int, ae_max : LibC::Double*, ae_ind : LibC::Int*, re_max : LibC::Double*, re_ind : LibC::Int*)
  fun print_sol = glp_print_sol(p : Prob, fname : LibC::Char*) : LibC::Int
  fun read_sol = glp_read_sol(p : Prob, fname : LibC::Char*) : LibC::Int
  fun write_sol = glp_write_sol(p : Prob, fname : LibC::Char*) : LibC::Int
  fun print_ranges = glp_print_ranges(p : Prob, len : LibC::Int, list : LibC::Int*, flags : LibC::Int, fname : LibC::Char*) : LibC::Int
  fun print_ipt = glp_print_ipt(p : Prob, fname : LibC::Char*) : LibC::Int
  fun read_ipt = glp_read_ipt(p : Prob, fname : LibC::Char*) : LibC::Int
  fun write_ipt = glp_write_ipt(p : Prob, fname : LibC::Char*) : LibC::Int
  fun print_mip = glp_print_mip(p : Prob, fname : LibC::Char*) : LibC::Int
  fun read_mip = glp_read_mip(p : Prob, fname : LibC::Char*) : LibC::Int
  fun write_mip = glp_write_mip(p : Prob, fname : LibC::Char*) : LibC::Int
  fun bf_exists = glp_bf_exists(p : Prob) : LibC::Int
  fun factorize = glp_factorize(p : Prob) : LibC::Int
  fun bf_updated = glp_bf_updated(p : Prob) : LibC::Int
  fun get_bfcp = glp_get_bfcp(p : Prob, parm : Bfcp*)

  struct Bfcp
    msg_lev : LibC::Int
    type : LibC::Int
    lu_size : LibC::Int
    piv_tol : LibC::Double
    piv_lim : LibC::Int
    suhl : LibC::Int
    eps_tol : LibC::Double
    max_gro : LibC::Double
    nfs_max : LibC::Int
    upd_tol : LibC::Double
    nrs_max : LibC::Int
    rs_size : LibC::Int
    foo_bar : LibC::Double[38]
  end

  fun set_bfcp = glp_set_bfcp(p : Prob, parm : Bfcp*)
  fun get_bhead = glp_get_bhead(p : Prob, k : LibC::Int) : LibC::Int
  fun get_row_bind = glp_get_row_bind(p : Prob, i : LibC::Int) : LibC::Int
  fun get_col_bind = glp_get_col_bind(p : Prob, j : LibC::Int) : LibC::Int
  fun ftran = glp_ftran(p : Prob, x : LibC::Double*)
  fun btran = glp_btran(p : Prob, x : LibC::Double*)
  fun warm_up = glp_warm_up(p : Prob) : LibC::Int
  fun eval_tab_row = glp_eval_tab_row(p : Prob, k : LibC::Int, ind : LibC::Int*, val : LibC::Double*) : LibC::Int
  fun eval_tab_col = glp_eval_tab_col(p : Prob, k : LibC::Int, ind : LibC::Int*, val : LibC::Double*) : LibC::Int
  fun transform_row = glp_transform_row(p : Prob, len : LibC::Int, ind : LibC::Int*, val : LibC::Double*) : LibC::Int
  fun transform_col = glp_transform_col(p : Prob, len : LibC::Int, ind : LibC::Int*, val : LibC::Double*) : LibC::Int
  fun prim_rtest = glp_prim_rtest(p : Prob, len : LibC::Int, ind : LibC::Int*, val : LibC::Double*, dir : LibC::Int, eps : LibC::Double) : LibC::Int
  fun dual_rtest = glp_dual_rtest(p : Prob, len : LibC::Int, ind : LibC::Int*, val : LibC::Double*, dir : LibC::Int, eps : LibC::Double) : LibC::Int
  fun analyze_bound = glp_analyze_bound(p : Prob, k : LibC::Int, value1 : LibC::Double*, var1 : LibC::Int*, value2 : LibC::Double*, var2 : LibC::Int*)
  fun analyze_coef = glp_analyze_coef(p : Prob, k : LibC::Int, coef1 : LibC::Double*, var1 : LibC::Int*, value1 : LibC::Double*, coef2 : LibC::Double*, var2 : LibC::Int*, value2 : LibC::Double*)
  fun npp_alloc_wksp = glp_npp_alloc_wksp : Prep
  fun npp_load_prob = glp_npp_load_prob(prep : Prep, p : Prob, sol : LibC::Int, names : LibC::Int)
  fun npp_preprocess1 = glp_npp_preprocess1(prep : Prep, hard : LibC::Int) : LibC::Int
  fun npp_build_prob = glp_npp_build_prob(prep : Prep, q : Prob)
  fun npp_postprocess = glp_npp_postprocess(prep : Prep, q : Prob)
  fun npp_obtain_sol = glp_npp_obtain_sol(prep : Prep, p : Prob)
  fun npp_free_wksp = glp_npp_free_wksp(prep : Prep)
  fun ios_reason = glp_ios_reason(t : Tree) : LibC::Int
  fun ios_get_prob = glp_ios_get_prob(t : Tree) : Prob
  fun ios_tree_size = glp_ios_tree_size(t : Tree, a_cnt : LibC::Int*, n_cnt : LibC::Int*, t_cnt : LibC::Int*)
  fun ios_curr_node = glp_ios_curr_node(t : Tree) : LibC::Int
  fun ios_next_node = glp_ios_next_node(t : Tree, p : LibC::Int) : LibC::Int
  fun ios_prev_node = glp_ios_prev_node(t : Tree, p : LibC::Int) : LibC::Int
  fun ios_up_node = glp_ios_up_node(t : Tree, p : LibC::Int) : LibC::Int
  fun ios_node_level = glp_ios_node_level(t : Tree, p : LibC::Int) : LibC::Int
  fun ios_node_bound = glp_ios_node_bound(t : Tree, p : LibC::Int) : LibC::Double
  fun ios_best_node = glp_ios_best_node(t : Tree) : LibC::Int
  fun ios_mip_gap = glp_ios_mip_gap(t : Tree) : LibC::Double
  fun ios_node_data = glp_ios_node_data(t : Tree, p : LibC::Int) : Void*
  fun ios_row_attr = glp_ios_row_attr(t : Tree, i : LibC::Int, attr : Attr*)

  struct Attr
    level : LibC::Int
    origin : LibC::Int
    klass : LibC::Int
    foo_bar : LibC::Double[7]
  end

  fun ios_pool_size = glp_ios_pool_size(t : Tree) : LibC::Int
  fun ios_add_row = glp_ios_add_row(t : Tree, name : LibC::Char*, klass : LibC::Int, flags : LibC::Int, len : LibC::Int, ind : LibC::Int*, val : LibC::Double*, type : LibC::Int, rhs : LibC::Double) : LibC::Int
  fun ios_del_row = glp_ios_del_row(t : Tree, i : LibC::Int)
  fun ios_clear_pool = glp_ios_clear_pool(t : Tree)
  fun ios_can_branch = glp_ios_can_branch(t : Tree, j : LibC::Int) : LibC::Int
  fun ios_branch_upon = glp_ios_branch_upon(t : Tree, j : LibC::Int, sel : LibC::Int)
  fun ios_select_node = glp_ios_select_node(t : Tree, p : LibC::Int)
  fun ios_heur_sol = glp_ios_heur_sol(t : Tree, x : LibC::Double*) : LibC::Int
  fun ios_terminate = glp_ios_terminate(t : Tree)
  fun init_mpscp = glp_init_mpscp(parm : Mpscp*)

  struct Mpscp
    blank : LibC::Int
    obj_name : LibC::Char*
    tol_mps : LibC::Double
    foo_bar : LibC::Double[17]
  end

  fun read_mps = glp_read_mps(p : Prob, fmt : LibC::Int, parm : Mpscp*, fname : LibC::Char*) : LibC::Int
  fun write_mps = glp_write_mps(p : Prob, fmt : LibC::Int, parm : Mpscp*, fname : LibC::Char*) : LibC::Int
  fun init_cpxcp = glp_init_cpxcp(parm : Cpxcp*)

  struct Cpxcp
    foo_bar : LibC::Double[20]
  end

  fun read_lp = glp_read_lp(p : Prob, parm : Cpxcp*, fname : LibC::Char*) : LibC::Int
  fun write_lp = glp_write_lp(p : Prob, parm : Cpxcp*, fname : LibC::Char*) : LibC::Int
  fun read_prob = glp_read_prob(p : Prob, flags : LibC::Int, fname : LibC::Char*) : LibC::Int
  fun write_prob = glp_write_prob(p : Prob, flags : LibC::Int, fname : LibC::Char*) : LibC::Int
  fun mpl_alloc_wksp = glp_mpl_alloc_wksp : Tran
  fun mpl_init_rand = glp_mpl_init_rand(tran : Tran, seed : LibC::Int)
  fun mpl_read_model = glp_mpl_read_model(tran : Tran, fname : LibC::Char*, skip : LibC::Int) : LibC::Int
  fun mpl_read_data = glp_mpl_read_data(tran : Tran, fname : LibC::Char*) : LibC::Int
  fun mpl_generate = glp_mpl_generate(tran : Tran, fname : LibC::Char*) : LibC::Int
  fun mpl_build_prob = glp_mpl_build_prob(tran : Tran, prob : Prob)
  fun mpl_postsolve = glp_mpl_postsolve(tran : Tran, prob : Prob, sol : LibC::Int) : LibC::Int
  fun mpl_free_wksp = glp_mpl_free_wksp(tran : Tran)
  fun read_cnfsat = glp_read_cnfsat(p : Prob, fname : LibC::Char*) : LibC::Int
  fun check_cnfsat = glp_check_cnfsat(p : Prob) : LibC::Int
  fun write_cnfsat = glp_write_cnfsat(p : Prob, fname : LibC::Char*) : LibC::Int
  fun minisat1 = glp_minisat1(p : Prob) : LibC::Int
  fun intfeas1 = glp_intfeas1(p : Prob, use_bound : LibC::Int, obj_bound : LibC::Int) : LibC::Int
  fun init_env = glp_init_env : LibC::Int
  fun version = glp_version : LibC::Char*
  fun config = glp_config(option : LibC::Char*) : LibC::Char*
  fun free_env = glp_free_env : LibC::Int
  fun puts = glp_puts(s : LibC::Char*)
  fun printf = glp_printf(fmt : LibC::Char*, ...)
  fun vprintf = glp_vprintf(fmt : LibC::Char*, arg : LibC::VaList)
  fun term_out = glp_term_out(flag : LibC::Int) : LibC::Int
  fun term_hook = glp_term_hook(func : (Void*, LibC::Char* -> LibC::Int), info : Void*)
  fun open_tee = glp_open_tee(name : LibC::Char*) : LibC::Int
  fun close_tee = glp_close_tee : LibC::Int
  fun error_ = glp_error_(file : LibC::Char*, line : LibC::Int) : Errfunc
  alias Errfunc = (LibC::Char* -> Void)
  fun at_error = glp_at_error : LibC::Int
  fun assert_ = glp_assert_(expr : LibC::Char*, file : LibC::Char*, line : LibC::Int)
  fun error_hook = glp_error_hook(func : (Void* -> Void), info : Void*)
  fun alloc = glp_alloc(n : LibC::Int, size : LibC::Int) : Void*
  fun realloc = glp_realloc(ptr : Void*, n : LibC::Int, size : LibC::Int) : Void*
  fun free = glp_free(ptr : Void*)
  fun mem_limit = glp_mem_limit(limit : LibC::Int)
  fun mem_usage = glp_mem_usage(count : LibC::Int*, cpeak : LibC::Int*, total : LibC::SizeT*, tpeak : LibC::SizeT*)
  fun time = glp_time : LibC::Double
  fun difftime = glp_difftime(t1 : LibC::Double, t0 : LibC::Double) : LibC::Double

  struct Graph
    pool : Void*
    name : LibC::Char*
    nv_max : LibC::Int
    nv : LibC::Int
    na : LibC::Int
    v : Vertex**
    index : Void*
    v_size : LibC::Int
    a_size : LibC::Int
  end

  struct Vertex
    i : LibC::Int
    name : LibC::Char*
    entry : Void*
    data : Void*
    temp : Void*
    in : Arc*
    out : Arc*
  end

  struct Arc
    tail : Vertex*
    head : Vertex*
    data : Void*
    temp : Void*
    t_prev : Arc*
    t_next : Arc*
    h_prev : Arc*
    h_next : Arc*
  end

  fun create_graph = glp_create_graph(v_size : LibC::Int, a_size : LibC::Int) : Graph*
  fun set_graph_name = glp_set_graph_name(g : Graph*, name : LibC::Char*)
  fun add_vertices = glp_add_vertices(g : Graph*, nadd : LibC::Int) : LibC::Int
  fun set_vertex_name = glp_set_vertex_name(g : Graph*, i : LibC::Int, name : LibC::Char*)
  fun add_arc = glp_add_arc(g : Graph*, i : LibC::Int, j : LibC::Int) : Arc*
  fun del_vertices = glp_del_vertices(g : Graph*, ndel : LibC::Int, num : LibC::Int*)
  fun del_arc = glp_del_arc(g : Graph*, a : Arc*)
  fun erase_graph = glp_erase_graph(g : Graph*, v_size : LibC::Int, a_size : LibC::Int)
  fun delete_graph = glp_delete_graph(g : Graph*)
  fun create_v_index = glp_create_v_index(g : Graph*)
  fun find_vertex = glp_find_vertex(g : Graph*, name : LibC::Char*) : LibC::Int
  fun delete_v_index = glp_delete_v_index(g : Graph*)
  fun read_graph = glp_read_graph(g : Graph*, fname : LibC::Char*) : LibC::Int
  fun write_graph = glp_write_graph(g : Graph*, fname : LibC::Char*) : LibC::Int
  fun mincost_lp = glp_mincost_lp(p : Prob, g : Graph*, names : LibC::Int, v_rhs : LibC::Int, a_low : LibC::Int, a_cap : LibC::Int, a_cost : LibC::Int)
  fun mincost_okalg = glp_mincost_okalg(g : Graph*, v_rhs : LibC::Int, a_low : LibC::Int, a_cap : LibC::Int, a_cost : LibC::Int, sol : LibC::Double*, a_x : LibC::Int, v_pi : LibC::Int) : LibC::Int
  fun mincost_relax4 = glp_mincost_relax4(g : Graph*, v_rhs : LibC::Int, a_low : LibC::Int, a_cap : LibC::Int, a_cost : LibC::Int, crash : LibC::Int, sol : LibC::Double*, a_x : LibC::Int, a_rc : LibC::Int) : LibC::Int
  fun maxflow_lp = glp_maxflow_lp(p : Prob, g : Graph*, names : LibC::Int, s : LibC::Int, t : LibC::Int, a_cap : LibC::Int)
  fun maxflow_ffalg = glp_maxflow_ffalg(g : Graph*, s : LibC::Int, t : LibC::Int, a_cap : LibC::Int, sol : LibC::Double*, a_x : LibC::Int, v_cut : LibC::Int) : LibC::Int
  fun check_asnprob = glp_check_asnprob(g : Graph*, v_set : LibC::Int) : LibC::Int
  fun asnprob_lp = glp_asnprob_lp(p : Prob, form : LibC::Int, g : Graph*, names : LibC::Int, v_set : LibC::Int, a_cost : LibC::Int) : LibC::Int
  fun asnprob_okalg = glp_asnprob_okalg(form : LibC::Int, g : Graph*, v_set : LibC::Int, a_cost : LibC::Int, sol : LibC::Double*, a_x : LibC::Int) : LibC::Int
  fun asnprob_hall = glp_asnprob_hall(g : Graph*, v_set : LibC::Int, a_x : LibC::Int) : LibC::Int
  fun cpp = glp_cpp(g : Graph*, v_t : LibC::Int, v_es : LibC::Int, v_ls : LibC::Int) : LibC::Double
  fun read_mincost = glp_read_mincost(g : Graph*, v_rhs : LibC::Int, a_low : LibC::Int, a_cap : LibC::Int, a_cost : LibC::Int, fname : LibC::Char*) : LibC::Int
  fun write_mincost = glp_write_mincost(g : Graph*, v_rhs : LibC::Int, a_low : LibC::Int, a_cap : LibC::Int, a_cost : LibC::Int, fname : LibC::Char*) : LibC::Int
  fun read_maxflow = glp_read_maxflow(g : Graph*, s : LibC::Int*, t : LibC::Int*, a_cap : LibC::Int, fname : LibC::Char*) : LibC::Int
  fun write_maxflow = glp_write_maxflow(g : Graph*, s : LibC::Int, t : LibC::Int, a_cap : LibC::Int, fname : LibC::Char*) : LibC::Int
  fun read_asnprob = glp_read_asnprob(g : Graph*, v_set : LibC::Int, a_cost : LibC::Int, fname : LibC::Char*) : LibC::Int
  fun write_asnprob = glp_write_asnprob(g : Graph*, v_set : LibC::Int, a_cost : LibC::Int, fname : LibC::Char*) : LibC::Int
  fun read_ccdata = glp_read_ccdata(g : Graph*, v_wgt : LibC::Int, fname : LibC::Char*) : LibC::Int
  fun write_ccdata = glp_write_ccdata(g : Graph*, v_wgt : LibC::Int, fname : LibC::Char*) : LibC::Int
  fun netgen = glp_netgen(g : Graph*, v_rhs : LibC::Int, a_cap : LibC::Int, a_cost : LibC::Int, parm : LibC::Int[16]) : LibC::Int
  fun netgen_prob = glp_netgen_prob(nprob : LibC::Int, parm : LibC::Int[16])
  fun gridgen = glp_gridgen(g : Graph*, v_rhs : LibC::Int, a_cap : LibC::Int, a_cost : LibC::Int, parm : LibC::Int[15]) : LibC::Int
  fun rmfgen = glp_rmfgen(g : Graph*, s : LibC::Int*, t : LibC::Int*, a_cap : LibC::Int, parm : LibC::Int[6]) : LibC::Int
  fun weak_comp = glp_weak_comp(g : Graph*, v_num : LibC::Int) : LibC::Int
  fun strong_comp = glp_strong_comp(g : Graph*, v_num : LibC::Int) : LibC::Int
  fun top_sort = glp_top_sort(g : Graph*, v_num : LibC::Int) : LibC::Int
  fun wclique_exact = glp_wclique_exact(g : Graph*, v_wgt : LibC::Int, sol : LibC::Double*, v_set : LibC::Int) : LibC::Int
end
