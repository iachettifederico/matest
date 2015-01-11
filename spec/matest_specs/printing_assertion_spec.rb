scope "hola" do
  let(:three) { 3 }
  xspec "chau" do
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

  spec  do
    a = 4

    a == 5
  end
end

# @one_plus_two == @res.to_i => false
# @one_plus_two => 4
# @res => "3"
# @res.to_i => 3


## ON EXAMPLE
# on call:
#   - run the spec without the assertion
#   - save the state
#   - and then run the assertion.
