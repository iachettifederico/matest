require "matest/version"
require "matest/example_block"
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
    def initialize(example_block, description, lets)
      @example_block__for_internal_use = ExampleBlock.new(example_block)
      @description__for_internal_use = description
      lets.each do |let|
        self.class.let(let.var_name, &let.block)
        send(let.var_name) if let.bang
      end
    end

    def example_block
      @example_block__for_internal_use
    end

    def description
      @description__for_internal_use
    end

    def call
      instance_eval(&example_block.block)
    end

    def self.let(var_name, &block)
      define_method(var_name) do
        instance_variable_set(:"@#{var_name}__from_let", block.call)
      end
    end

    def self.local_var(var_name)
      define_method(var_name) do
        instance_variable_get(:"@#{var_name}")
      end
      define_method("#{var_name}=") do |value|
        instance_variable_set(:"@#{var_name}", value)
      end
    end

    def track_variables
      instance_variables.reject {|var|
        var.to_s =~ /__for_internal_use\Z/ || var.to_s =~ /__from_let\Z/
      }.map {|var| [var, instance_variable_get(var)] }
    end

    def track_lets
      instance_variables.select {|var|
        var.to_s =~ /__from_let\Z/
      }.map {|var|
        name = var.to_s
        name["__from_let"] = ""
        name[0] = ""
        [name, instance_variable_get(var)]
      }
    end

    def without_block
      the_new = self.clone
      the_new.instance_variable_set(:@example_block__for_internal_use, nil)
      the_new
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
      current_example = block_given? ? block : ->(*) { Matest::SkipMe.new }
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

def scope(description=nil, &block)
  Matest::Runner.runner << Matest::ExampleGroup.new(block)
end

def xscope(description=nil, &block)
  # no-op
end

alias :describe :scope
alias :xdescribe :xscope

alias :context :scope
alias :xcontext :xscope

alias :group :scope
alias :xgroup :xscope
