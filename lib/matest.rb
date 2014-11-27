require "matest/version"
require "matest/spec_status"
module Matest
  class Runner
    attr_reader :example_groups
    attr_reader :info

    def initialize
      @example_groups = []
      @info = {}
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
      print_messages
    end

    def print_messages
      puts "\n\n### Messages ###"

      statuses = []
      info[:success] = true
      info[:num_specs] = { total: 0 }
      
      example_groups.each do |current_group|
        current_group.statuses.each do |status|
          info[:num_specs][:total] += 1

          info[:num_specs][status.name] ||= 0
          info[:num_specs][status.name] += 1

          if status.is_a?(Matest::SpecPassed)
          else
            if status.is_a?(Matest::SpecFailed)
              info[:success] = false
            end
            puts "\n[#{status.name}] #{status.description}"
            if status.is_a?(Matest::NotANaturalAssertion)
              info[:success] = false
              puts "  # => #{status.result.inspect}"
            end
            if status.is_a?(Matest::ExceptionRaised)
              info[:success] = false
              puts "EXCEPTION >> #{status.result}"
              status.result.backtrace.each do |l|
                puts "  #{l}"
              end

            end
            puts "  #{status.location}:"
          end
        end
      end
    end
  end


  class SkipMe; end
  
  class ExampleGroup
    attr_reader :scope_block
    attr_reader :specs
    attr_reader :statuses

    def initialize(scope_block)
      @scope_block = scope_block
      @specs       = []
      @statuses    = []
    end

    def execute!
      instance_eval(&scope_block)
      specs.shuffle.each do |spec, desc|
        res = run_spec(spec, desc)
        print res
      end

    end

    def spec(description=nil, &block)
      current_example = block_given? ? block : -> { Matest::SkipMe.new }
      specs << [current_example, description]
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

    def let(var_name, &block)
      self.class.let(var_name, &block)
    end

    def let!(var_name, &block)
      self.class.let(var_name, &block)
      send(var_name)
    end

    def run_spec(spec, description)
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
                 status_class.new(spec, result, description)
               rescue Exception => e
                 Matest::ExceptionRaised.new(spec, e, description)
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
