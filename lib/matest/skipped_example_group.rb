module Matest
  class SkippedExampleGroup
    attr_reader :scope_block

    attr_accessor :printer
    attr_reader :specs
    attr_reader :statuses

    def initialize(scope_block)
      @scope_block = scope_block
      @specs       = []
      @statuses       = []
    end

    def execute!
      instance_eval(&scope_block)
      specs.each do |spec|
        res = run_spec(spec)
        printer.print(res)
      end
    end

    def run_spec(spec)
      status = Matest::SpecSkipped.new(spec, true)
      @statuses << status
      status
    end

    def let(*args)
    end

    def let!(*args)
    end

    def scope(description=nil, &block)
      Matest::Runner.runner << Matest::SkippedExampleGroup.new(block)
    end
    alias :xscope :scope
    alias :describe :scope
    alias :xdescribe :xscope

    alias :context :scope
    alias :xcontext :xscope

    alias :group :scope
    alias :xgroup :xscope

    def spec(description=nil, &block)
      current_example = ->(*args) { Matest::SkipMe.new }
      specs << Example.new(current_example, description, [])
    end
    alias :xspec :spec
    alias :example :spec
    alias :xexample :spec
    alias :it :spec
    alias :xit :spec
  end
end
