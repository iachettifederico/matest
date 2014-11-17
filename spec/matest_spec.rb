require "spec_helper"

def get_statuses(&block)
  group = block.call.first
  group.execute!
  group.statuses
end
describe "scope" do
  it "can pass" do
    statuses = get_statuses do
      scope do
        spec do
          true
        end
      end
    end
    statuses.first.must_be_kind_of(Matest::SpecPassed)
  end
end

describe "spec" do
  describe "passing" do
    it "passes" do
      scope do
        res = spec do
          true
        end
        res.must_be_kind_of(Matest::SpecPassed)
      end
    end
    it "forwards the block" do
      scope do
        res = spec do
          true
        end
        res.block.call.must_equal(true)
      end
    end

    it "allows a description and forwards it" do
      scope do
        res = spec "THE DESCRIPTION" do
          true
        end
        res.description.must_equal("THE DESCRIPTION")
      end
    end
  end

  describe "failing" do
    it "fails" do
      scope do
        res = spec do
          false
        end
        res.must_be_kind_of(Matest::SpecFailed)
      end
    end

    it "forwards the block" do
      scope do
        res = spec do
          false
        end
        res.block.call.must_equal(false)
      end
    end

    it "allows a description and forwards it" do
      scope do
        res = spec "THE DESCRIPTION" do
          false
        end
        res.description.must_equal("THE DESCRIPTION")
      end
    end
  end

  it "only allows natural assertions" do
    scope do
      res = spec do
        :not_true_nor_false
      end
      res.must_be_kind_of(Matest::NotANaturalAssertion)
    end
  end

  it "skips if no block is given" do
    scope do
      res = spec
      res.must_be_kind_of(Matest::SpecSkipped)
    end
  end

  it "allows raising an exception" do
    scope do
      res = spec do
        raise RuntimeError
      end
      res.must_be_kind_of(Matest::ExceptionRaised)
    end
  end

  it "exists only inside a scope" do
    spec do
      true
    end

  end
end

describe "xspec" do
  it "skips" do
    scope do
      res = xspec do
        raise "Wanna raise an error? do it ... nothing will happen"
        :whatever
      end
      res.must_be_kind_of(Matest::SpecSkipped)
    end
  end

  it "forwards the block" do
    scope do
      res = xspec do
        false
      end
      res.block.call.must_equal(false)
    end
  end

  it "allows a description and forwards it" do
    scope do
      res = spec "THE DESCRIPTION" do
        false
      end
      res.description.must_equal("THE DESCRIPTION")
    end
  end
end
