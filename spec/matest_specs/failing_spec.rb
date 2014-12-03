scope do
  let(:a) { true }
  spec do
    @b = false
    !(a == @b)
  end
end
