require "./spec_helper"

describe "GLPK" do
  it "works" do
    puts "GLPK Version: "+String.new(LibGLPK.version)
  end
end


