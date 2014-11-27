require "matest/version"
require "matest/spec_status"
require "matest/spec_printer"


module Matest
  class Runner
    attr_reader :example_groups
    attr_reader :info
    attr_reader :printer

    def initialize(options={})
      @example_groups = []
      @info           = {}
      @printer        = options[:printer] || SpecPrinter.new
    end

    def self.runner
      @runner ||= new
    end

    def <<(example_group)
      example_groups << example_group
    end

    def load_file(file)
      load(file)
    end

    def execute!
      example_groups.each do |current_group|
        current_group.execute!
      end
      printer.print(self)
    end
  end

  class SkipMe; end

  class Example
    def example_block
      @__example_block
    end
    def description
      @__description
    end

    def initialize(example_block, description, lets)
      @__example_block = example_block
      @__description = description
      lets.each do |let|
        self.class.let(let.var_name, &let.block)
        send(let.var_name) if let.bang
      end
    end

    def call
      instance_eval(&example_block)
    end

    def self.let(var_name, &block)
      define_method(var_name) do
        instance_variable_set(:"@#{var_name}", block.call)
      end
    end

    def track
      instance_variables.reject {|i| i.to_s =~ /\A@__/}.map {|i| [i, instance_variable_get(i)] }
    end
  end

  class Let
    attr_reader :var_name
    attr_reader :block
    attr_reader :bang

    def initialize(var_name, block, bang=false)
      @var_name = var_name
      @block = block
      @bang = bang
    end
  end

  class ExampleGroup
    attr_reader :scope_block
    attr_reader :specs
    attr_reader :lets
    attr_reader :statuses

    def initialize(scope_block)
      @scope_block = scope_block
      @specs       = []
      @lets        = []
      @statuses    = []
    end

    def spec(description=nil, &block)
      current_example = block_given? ? block : -> { Matest::SkipMe.new }
      specs << Example.new(current_example, description, lets)
    end

    def execute!
      instance_eval(&scope_block)
      specs.shuffle.each do |spec, desc|
        res = run_spec(spec)
        print res
      end

    end

    def xspec(description=nil, &block)
      spec(description)
    end

    [:it, :test, :example].each do |m|
      alias :"#{m}" :spec
      alias :"x#{m}" :xspec
    end

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

def scope(description=nil, &block)
  Matest::Runner.runner << Matest::ExampleGroup.new(block)
end

def xscope(description=nil, &block)
  # no-op
end

[:describe, :context, :group].each do |m|
  alias :"#{m}" :scope
  alias :"x#{m}" :xscope
end
