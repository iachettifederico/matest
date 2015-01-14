scope do
  let(:three) { 3 }
  spec "variables and lets" do
    one = 2
    two = 2

    @one_plus_two_plus_three = one + two + three
    @res = 3

    @one_plus_two_plus_three.to_i == @res
  end

  spec "again?" do
    @arr = %w[a b c d e]

    @arr.pop == "k"
  end

  spec "not natural" do
    one = 2
    two = 2

    @one_plus_two_plus_three = one + two + three
    @res = 3

    @res = @one_plus_two_plus_three.to_i + @res.to_i
  end

end
