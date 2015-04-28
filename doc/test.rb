require "simplecov"             # => true
require "callable"              # => true

module Matest
  module SelectorStrategies
    module All
      def self.call(collection)
        collection
      end
    end

    class Tag
      def initialize(tag)
        @tag = tag
      end

      def call(collection)
        collection.select { |spec| spec.tag == @tag}
      end
    end
    class ByFileAndLineNum
      attr_reader :file
      attr_reader :line
      def initialize(file, line)
        @file = file
        @line = line
      end

      def call(collection)
        puts "TODO: select spec by file and line no"
      end
    end
  end

  module OrderStrategies
    module Random
      def self.call(collection)
        collection.shuffle
      end
    end
    module Reverse
      def self.call(collection)
        collection.reverse
      end
    end
  end
  def self.runner(**options)
    @runner ||= Runner.new(**options)
  end

  def self.spec_methods
    %i[spec example it test]
  end

  def self.scope_methods
    %i[scope describe context]
  end

  def self.special_methods
    spec_methods + scope_methods
  end

  Undefined = Class.new
  class Runner
    SPECS = []
    attr_reader :order
    attr_reader :selector
    attr_reader :printer

    def initialize(order: Matest::OrderStrategies::Random,
                   selector: Matest::SelectorStrategies::All,
                   printer: SpecPrinter.new,
                   **options)
      @order    = order
      @selector = selector
      @printer  = printer
    end

    def <<(spec)
      Matest.special_methods.each do |m|
        undef :"#{m}" rescue nil
      end
      SPECS << spec
    end

    def run
      specs = selector.call(SPECS)
      order.call(specs).each do |spec|
        spec.execute!
      end
      printer.render
    end
  end

  class Spec
    attr_reader :block
    attr_reader :tag
    def initialize(description=Undefined, tag: Undefined, **options, &block)
      @description = description
      @block = block
      @spec_count = 0
      @tag = tag
    end

    def let(var_name)
      self.class.class_eval do
        define_method(var_name) do
          instance_variable_set("@#{var_name}", yield)
        end
      end
    end

    def scope(description=Undefined, &block)
      spec_class = self.class.const_set(spec_class_name, Class.new(self.class))
      spec_class.new(description, &block).tap do |s|
        if block_given?
          s.instance_eval(&block)
        else
          spec(description)
        end
      end
    end

    def spec(description=Undefined, **options, &block)
      spec_class = self.class.const_set(spec_class_name, Class.new(self.class))
      Matest.runner << spec_class.new(description, **options, &block)
    end

    def execute!
      SpecRunner.new(self).run
    end

    def skip
      raise Matest::Status::Skip
    end

    private

    def spec_class_name
      [
       self.class.to_s,
       "_",
       @spec_count += 1
      ].join.split("::").last
    end

  end

  class SpecRunner
    attr_reader :spec
    def initialize(spec)
      @spec = spec
    end

    def run
      Matest.runner.printer << Status.for(spec.block)
    end
  end

  class Status
    class SpecPassed < Status; end
    class SpecFailed < Status; end
    class SpecSkipped < Status; end
    class NotNaturalAssertion < Status; end
    class ExceptionRaised < Status
      def to_s
        super + result.backtrace.inspect
      end
    end
    class Skip < Exception
      def self.call
        self
      end
    end
    STATUSES = {
                true => SpecPassed,
                false => SpecFailed,
                Skip => SpecSkipped,
               }
    STATUSES.default = NotNaturalAssertion

    attr_reader :result
    def initialize(result)
      @result = result
    end

    def self.for(block=Skip)
      # TODO: Cambiar raise por throw!
      res = begin
              (block || Skip).call
            rescue Skip
              Skip
            end
      STATUSES[res].new(res)

    rescue Exception => ex
      ExceptionRaised.new(ex)
    end

    def to_s
      "<#{self.class} result: #{result.inspect}>"
    end

  end

  class SpecPrinter
    def <<(status)
      puts status
    end

    def render
    end
  end
end

module Kernel
  def scope(description=Matest::Undefined, &block)
    Matest::Spec.new(description, &block).tap do |s|
      s.instance_eval(&block)
    end
  end
end


class ComplexPrinter
  STATUSES = []
  def <<(status)
    puts status
    STATUSES << status
  end

  def render
    puts "\nMessages:\n\n\n"
    STATUSES.each do |status|
      puts "  -> #{status.result}"
    end
  end
end

Matest.runner printer: ComplexPrinter.new, selector: Matest::SelectorStrategies::Tag.new(:wip)

scope {
  scope
  spec { "XXXXXXXXXXXXXXXXXXXX"}
  spec(tag: :wip) {
    skip
    "WIP 1" }
  spec { 2 }
  scope {
    spec(tag: :wwip) {
      "WWIP 3"
    }
  }
  scope {
    spec(tag: :wip) { "Wip 4" }
    spec { false }
  }
  scope {
    spec { 6 }
    spec
    spec { true }
    spec { false }
    scope
  }
}

Matest.runner.run

# >> <Matest::Status::NotNaturalAssertion result: "Wip 4">
# >> <Matest::Status::SpecSkipped result: Matest::Status::Skip>
# >>
# >> Messages:
# >>
# >>
# >>   -> Wip 4
# >>   -> Matest::Status::Skip
