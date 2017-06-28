require "./libCoinMP"

module CoinMP
  LibCoinMP.init_solver("")

  module Info
    def self.version
      LibCoinMP.get_version
    end

    def self.version_str
      String.new(LibCoinMP.get_version_str)
    end

    def self.name
      String.new(LibCoinMP.get_solver_name)
    end

    def self.features
      LibCoinMP::Feature.new(LibCoinMP.get_features)
    end

    def self.methods
      LibCoinMP::Method.new(LibCoinMP.get_methods)
    end

    def self.about
      "
    Name: #{name}
    Version: #{version}
    Features: #{features}
    Methods: #{methods}
    "
    end
  end
end
