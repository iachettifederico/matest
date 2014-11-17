scope do
  spec do
    1 == 1
  end

  spec "I shall fail" do
    false
  end

  spec do
    @hola = 5
    @hola == 5
  end

  spec do
    @hola == nil
  end

  spec do
    "not true nor false"
  end

  spec "I'm not natural" do
    "not true nor false w/desc"
  end

  spec "I raise" do
    raise IndexError
  end

  spec "I skip"

  xspec "I skip too" do
    false
  end
end

