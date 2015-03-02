require "spec_helper"

xscope do
  let(:three) { 3 }
  xspec "variables and lets" do
    one = 2
    two = 2

    @one_plus_two_plus_three = one + two + three
    @res = 3

    @one_plus_two_plus_three.to_i == @res
  end

  xspec "again?" do
    @arr = %w[a b c d e]

    @arr.pop == "k"
  end

  xspec "not natural" do
    one = 2
    two = 2

    @one_plus_two_plus_three = one + two + three
    @res = 3

    @res = @one_plus_two_plus_three.to_i + @res.to_i
  end
end
scope do
  let(:parser) { OpenStruct.new(args: []) }
  spec("AAAAAAAAAA") { parser.args == %w[first second] }
  spec("BBBBBBBBBB") {
    a = 5
    parser.args == %w[first second]
  }
  spec("CCCCCCCCCC") { parser.args == %w[first second] }
  spec { parser.args == %w[first second] }
end
