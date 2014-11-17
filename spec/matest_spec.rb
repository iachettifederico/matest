require "spec_helper"

describe "spec" do
  describe "passing" do
    it "passes" do
      res = spec do
        true
      end
      res.must_be_kind_of(Matest::SpecPassed)
    end

    it "forwards the block" do
      res = spec do
        true
      end
      res.block.call.must_equal(true)
    end

    it "allows a description and forwards it" do
      res = spec "THE DESCRIPTION" do
        true
      end
      res.description.must_equal("THE DESCRIPTION")
    end
  end

  describe "failing" do
    it "fails" do
      res = spec do
        false
      end
      res.must_be_kind_of(Matest::SpecFailed)
    end

    it "forwards the block" do
      res = spec do
        false
      end
      res.block.call.must_equal(false)
    end

    it "allows a description and forwards it" do
      res = spec "THE DESCRIPTION" do
        false
      end
      res.description.must_equal("THE DESCRIPTION")
    end

  end

  it "only allows natural assertions" do
    res = spec do
      :not_true_nor_false
    end
    res.must_be_kind_of(Matest::NotANaturalAssertion)
  end

  it "skips if no block is given" do
    res = spec
    res.must_be_kind_of(Matest::SpecSkipped)
  end

end

describe "xspec" do
  it "skips" do
    res = xspec do
      raise "Wanna raise an error? do it ... nothing will happen"
      :whatever
    end
    res.must_be_kind_of(Matest::SpecSkipped)
  end

  # it "forwards the block" do
  #   res = xspec do
  #     false
  #   end
  #   res.block.call.must_equal(false)
  # end
  #
  # it "allows a description and forwards it" do
  #   res = spec "THE DESCRIPTION" do
  #     false
  #   end
  #   res.description.must_equal("THE DESCRIPTION")
  # end
end

###
### spec do
###   5 == 5
### end
###
### spec do
###   5 == 6
### end
###
### spec do
###   skip
### end
###
### spec  do
###   10
### end
###
###
###
###
### # >> .
### # >>
### # >> F
### # >>
### # >> S
### # >>
### # >> X
### # >>
### # >> {:message=>"The spec needs to return either true or false, but it returned 10", :block=>#<Proc:0x00000001f61408@-:17>}
