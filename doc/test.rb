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
    class SpecPassed < Status
      def passing?
        true
      end
      def skipped?
        false
      end
      def short
        ?.
      end
      def name
        "Passing"
      end
    end
    class SpecFailed < Status
      def passing?
        false
      end
      def skipped?
        false
      end
      def short
        ?F
      end
      def name
        "Failed"
      end
    end
    class SpecSkipped < Status
      def passing?
        false
      end
      def skipped?
        true
      end
      def short
        ?S
      end
      def name
        "Skipped"
      end
    end
    class NotNaturalAssertion < Status
      def passing?
        false
      end
      def skipped?
        false
      end
      def short
        ?N
      end
      def name
        "Not Natural"
      end
    end
    class ExceptionRaised < Status
      def passing?
        false
      end
      def skipped?
        false
      end
      def to_s
        super + result.backtrace.inspect
      end
      def short
        ?E
      end
      def name
        "Exception Raised"
      end
    end
    class Skip < Exception
      def self.call
        self
      end

      def self.source_location
        caller.last.split(":")[0..1]
      end
    end
    STATUSES = {
                true => SpecPassed,
                false => SpecFailed,
                Skip => SpecSkipped,
               }
    STATUSES.default = NotNaturalAssertion

    attr_reader :result
    def initialize(result, block)
      @result = result
      @block = block || Skip
    end

    def self.for(block=Skip)
      res = begin
              (block || Skip).call
            rescue Skip
              Skip
            end
      STATUSES[res].new(res, block)

    rescue Exception => ex
      ExceptionRaised.new(ex)
    end

    def to_s
      "<#{self.class} result: #{result.inspect}>"
    end

    def location
      @block.source_location.join(":")
    end
  end

  class SpecPrinter
    STATUSES = []
    def <<(status)
      print status.short
      STATUSES << status unless status.passing?
    end

    def render
      puts "\nMessages:\n\n\n"
      STATUSES.each do |status|
        variables = unless status.passing? || status.skipped?
                      #status.spec
                      "VARIABLES HERE"
                    end

        message = [
                   "#{status.name}:",
                   "  Result:    #{status.result}",
                   "  Location:  #{status.location}",
                   "  Variables: #{variables}",
                  ].uniq
        puts message.join("\n")
      end
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



Matest.runner #, selector: Matest::SelectorStrategies::Tag.new(:wip)

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

start = Time.now
Matest.runner.run
Time.now - start                # => 0.000216104


# >> NSSNN.FNSSFN
# >> Messages:
# >> 
# >> 
# >> Not Natural:
# >>   Result:    WWIP 3
# >>   Location:  -:325
# >>   Variables: VARIABLES HERE
# >> Skipped:
# >>   Result:    Matest::Status::Skip
# >>   Location:  -:343
# >>   Variables: 
# >> Skipped:
# >>   Result:    Matest::Status::Skip
# >>   Location:  -:320
# >>   Variables: 
# >> Not Natural:
# >>   Result:    Wip 4
# >>   Location:  -:330
# >>   Variables: VARIABLES HERE
# >> Not Natural:
# >>   Result:    6
# >>   Location:  -:334
# >>   Variables: VARIABLES HERE
# >> Failed:
# >>   Result:    false
# >>   Location:  -:337
# >>   Variables: VARIABLES HERE
# >> Not Natural:
# >>   Result:    2
# >>   Location:  -:323
# >>   Variables: VARIABLES HERE
# >> Skipped:
# >>   Result:    Matest::Status::Skip
# >>   Location:  -:343
# >>   Variables: 
# >> Skipped:
# >>   Result:    Matest::Status::Skip
# >>   Location:  -:343
# >>   Variables: 
# >> Failed:
# >>   Result:    false
# >>   Location:  -:331
# >>   Variables: VARIABLES HERE
# >> Not Natural:
# >>   Result:    XXXXXXXXXXXXXXXXXXXX
# >>   Location:  -:319
# >>   Variables: VARIABLES HERE
