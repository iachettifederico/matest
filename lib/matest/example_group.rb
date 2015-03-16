module Matest
  class ExampleGroup
    attr_reader :scope_block
    attr_reader :specs
    attr_reader :lets
    attr_reader :statuses

    attr_accessor :printer

    def initialize(scope_block)
      @scope_block = scope_block
      @specs       = []
      @lets        = []
      @statuses    = []
    end

    def spec(description=nil, &block)
      current_example = block_given? ? block : Matest::SkipMe.new(caller)
      specs << Example.new(current_example, description, lets)
    end

    def xspec(description=nil, &block)
      current_example = Matest::SkipMe.new(caller)
      specs << Example.new(current_example, description, [])
    end

    def execute!
      instance_eval(&scope_block)
      specs.shuffle.each do |spec, desc|
        res = run_spec(spec)
        printer.prints(res)
      end

    end

    alias :it :spec
    alias :xit :xspec

    alias :test :spec
    alias :xtest :xspec

    alias :example :spec
    alias :xexample :xspec

    def self.let(var_name, &block)
      define_method(var_name) do
        instance_variable_set(:"@#{var_name}", block.call)
      end
    end

    def let(var_name, bang=false, &block)
      lets << Let.new(var_name, block, bang=false)
    end

    def let!(var_name, &block)
      lets << Let.new(var_name, block, bang=true)
    end

    def run_spec(spec)
      status = begin
                 result = spec.call
                 status_class = case result
                                when true
                                  Matest::SpecPassed
                                when false
                                  Matest::SpecFailed
                                when Matest::SkipMe
                                  Matest::SpecSkipped
                                else
                                  Matest::NotANaturalAssertion
                                end
                 status_class.new(spec, result)
               rescue Exception => e
                 Matest::ExceptionRaised.new(spec, e, spec.description)
               end
      @statuses << status
      status
    end
  end
end
