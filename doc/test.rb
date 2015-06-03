require "simplecov"             # => true
require "callable"              # => true
require "string_plus"           # => true

module Matest
  module SelectorStrategies
    def self.strategy(strategy_or_name)
      if strategy_or_name.respond_to?(:call)
        strategy_or_name
      else
        "::Matest::SelectorStrategies::#{strategy_or_name.to_s.camelcase}".constantize
      end
    end

    All = -> (collection) { collection }

    module Focus
      def self.call(collection)
        selected = collection.select { |spec| spec.focus == true}
        selected.empty? ? collection : selected
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
    def self.strategy(strategy_or_name)
      if strategy_or_name.respond_to?(:call)
        strategy_or_name
      else
        "::Matest::OrderStrategies::#{strategy_or_name.to_s.camelcase}".constantize
      end
    end

    Random  = -> (collection) { collection.shuffle }
    Natural = -> (collection) { collection         }
    Reverse = -> (collection) { collection.reverse }
  end

  def self.runner(**options)
    @runner ||= Runner.new(**options)
  end

  SPEC_METHODS    = %i[spec example it test]
  SCOPE_METHODS   = %i[scope describe context]
  SPECIAL_METHODS = SPEC_METHODS + SCOPE_METHODS

  Undefined = Class.new
  class Runner
    SPECS = []
    attr_reader :order
    attr_reader :selector
    attr_reader :printer

    def initialize(order:    Matest::OrderStrategies::Random,
                   selector: Matest::SelectorStrategies::Focus,
                   printer:  ExamplePrinter.new,
                   **options)
      @order    = Matest::OrderStrategies.strategy(order)
      @selector = Matest::SelectorStrategies.strategy(selector)
      @printer  = printer
    end

    def <<(spec)
      Matest::SPECIAL_METHODS.each do |m|
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

  class Example
    def initialize(description=Undefined, tag: Undefined, focus: false, **options, &block)
      @_description = description
      @_block       = block
      @_spec_count  = 0
      @_tag         = tag
      @_focus       = focus
    end

    def description; @_description end
    def block; @_block end
    def spec_count; @_spec_count end
    def increment_spec_count; @_spec_count += 1 end
    def tag; @_tag end
    def focus; @_focus end

    def let(var_name)
      self.class.class_eval do
        define_method(var_name) do
          instance_variable_set("@_#{var_name}__let", yield)
        end
      end
    end

    def scope(description=Undefined, &block)
      spec_class = self.class.const_set(spec_class_name, Class.new(self.class))
      spec_class.new(description, &block).tap do |s|
        block = Callable(block, default: spec(description))
        s.instance_eval(&block)
      end
    end

    def spec(description=Undefined, **options, &block)
      spec_class = self.class.const_set(spec_class_name, Class.new(self.class))
      spec_class.new(description, **options, &block).tap do |the_spec|
        Matest.runner << the_spec
      end
    end

    def execute!
      ExampleRunner.new(self).run
    end

    def skip
      raise Matest::Status::Skip
    end

    def variables
      instance_variables.select {|n| !n.to_s.start_with?("@_")}.
        each_with_object({}) { |var, result|
        result[var[1..-1]] = instance_variable_get(var)
      }
    end

    def lets
      instance_variables.select {|n| n.to_s.start_with?("@_") && n.to_s.end_with?("__let")}.
        each_with_object({}) { |var, result|
        result[var[2..-6]] = instance_variable_get(var)
      }
    end

    private

    def spec_class_name
      [
       self.class.to_s,
       "_",
       increment_spec_count
      ].join.split("::").last
    end

  end

  class ExampleRunner
    attr_reader :spec
    def initialize(spec)
      @spec = spec
    end

    def run
      Matest.runner.printer << Status.for(spec)
    end
  end

  class Status
    class ExamplePassed < Status
      def passing?; true end
      def skipped?; false end
      def short; ?. end
      def name; "Passing" end
    end

    class ExampleFailed < Status
      def passing?; false end
      def skipped?; false end
      def short; ?F end
      def name; "Failed" end
    end

    class ExampleSkipped < Status
      def passing?; false end
      def skipped?; true end
      def short; ?S end
      def name; "Skipped" end
    end

    class NotNaturalAssertion < Status
      def passing?; false end
      def skipped?; false end
      def short; ?N end
      def name; "Not Natural" end
    end

    class ExceptionRaised < Status
      def passing?; false end
      def skipped?; false end
      def to_s; super + result.backtrace.inspect end
      def short; ?E end
      def name; "Exception Raised" end
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
                true  => ExamplePassed,
                false => ExampleFailed,
                Skip  => ExampleSkipped,
               }
    STATUSES.default = NotNaturalAssertion

    attr_reader :result
    attr_reader :spec
    def initialize(result, spec)
      @result = result
      @spec   = spec
    end

    def self.for(spec)
      res = begin
              spec.instance_eval(&Callable(spec.block, default: Skip))
            rescue Skip
              Skip
            end
      STATUSES[res].new(res, spec)

    rescue Exception => ex
      ExceptionRaised.new(ex, spec)
    end

    def to_s
      "<#{self.class} result: #{result.inspect}>"
    end

    def location
      (spec.block || Skip).source_location.join(":")
    end

    def variables; spec.variables end
    def lets; spec.lets end
  end

  class ExamplePrinter
    STATUSES = []
    def <<(status)
      print status.short
      STATUSES << status unless status.passing?
    end

    def render
      puts "\nMessages:\n\n\n"
      STATUSES.each do |status|
        message = [
                   "#{status.name}:",
                   "  Result:    #{status.result}",
                   "  Location:  #{status.location}",
                   (format_vars("Variables", status.variables) unless status.skipped?),
                   (format_vars("Lets", status.lets) unless status.skipped?),
                  ].uniq
        puts message.join("\n")
      end
    end

    private

    def format_vars(title, vars)
      return if vars.empty?
      "  " + title + ":\n    " +
        vars.map { |name, value|
        "#{name}: #{value.inspect}" unless value == Matest::Undefined
      }.uniq.join("\n    ")
    end
  end

end

module Kernel
  def scope(description=Matest::Undefined, &block)
    Matest::Example.new(description, &block).tap do |s|
      s.instance_eval(&block)
    end
  end
end



Matest.runner order: :natural, selector: :focus #Matest::SelectorStrategies::Tag.new(:wip)

scope {
  let(:a) { 66 }
  spec(focus: true) { @ba = 5; a }
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
Time.now - start                # => 8.8037e-05


# >> N
# >> Messages:
# >>
# >>
# >> Not Natural:
# >>   Result:    66
# >>   Location:  -:323
# >>   Variables:
# >>     ba: 5
# >>   Lets:
# >>     a: 66
