require "matest/version"

module Matest
  class SpecStatus
    attr_reader :block
    attr_reader :description
    def initialize(block=nil, description=nil)
      @block = block
      @description = description
    end
  end

  class SpecPassed < SpecStatus; end
  class SpecFailed < SpecStatus; end
  class SpecSkipped < SpecStatus; end
  class NotANaturalAssertion < SpecStatus; end

  class SkipMe; end
end

def spec(description=nil, &block)
  res = block_given? ? block.call : Matest::SkipMe.new
  status_class = case res
                 when true
                   Matest::SpecPassed
                 when false
                   Matest::SpecFailed
                 when Matest::SkipMe
                   Matest::SpecSkipped
                 else
                   Matest::NotANaturalAssertion
                 end
  status_class.new(block, description)
end

def xspec(description=nil, &block)
  return Matest::SpecSkipped.new(block, description)
end
