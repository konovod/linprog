require "./spec_helper"

describe Solver do
  # TODO: Write tests

  it "works" do
    LibCoinMP.init_solver("")
    puts "
    Name: #{String.new(LibCoinMP.get_solver_name)}
    Version: #{LibCoinMP.get_version}
    Features: #{LibCoinMP::Feature.new(LibCoinMP.get_features)}
    Methods: #{LibCoinMP::Method.new(LibCoinMP.get_methods)}
      "
  end
end
