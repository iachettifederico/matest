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
  
  class ExceptionRaised < SpecStatus
    attr_reader :exception
    def initialize(block, description, exception)
      super(block, description)
      @exception = exception
    end
  end

  class SkipMe; end

  class ExampleGroup
    attr_reader :scope_block

    def initialize(scope_block)
      @scope_block = scope_block
    end

    def run
      instance_eval(&scope_block)
    end

    def spec(description=nil, &block)
      current_block = block_given? ? block : -> { Matest::SkipMe.new }
      begin
        status_class = case current_block.call
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
      rescue Exception => e
        Matest::ExceptionRaised.new(block, description, e)
      end
    end

    def xspec(description=nil, &block)
      return Matest::SpecSkipped.new(block, description)
    end

    [:it, :spec, :test, :example].each do |m|
      alias m :spec
      alias :"x#{m}" :xspec
    end
  end


end


def scope(&block)
  Matest::ExampleGroup.new(block).run
end
