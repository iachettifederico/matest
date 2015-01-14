module Matest
  class Example
    def initialize(example_block, description, lets)
      @example_block__for_internal_use = ExampleBlock.new(example_block)
      @description__for_internal_use = description
      @lets__for_internal_use = lets
      lets.each do |let|
        self.class.let(let.var_name, &let.block)
        send(let.var_name) if let.bang
      end
    end

    def lets
      @lets__for_internal_use
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

    # def without_block
    #   the_new = self.clone
    #   the_new.instance_variable_set(:@example_block__for_internal_use, nil)
    #   the_new
    # end

    def just_before_assertion
      # return a clone of self, but with
      ExampleBeforeAssertion.new(example_block.block, description, lets)
    end
  end

  private

  class ExampleBeforeAssertion < Example
    def initialize(example_block, description, lets)
      super
      set_state
    end

    def set_state
      before_sexp = example_block.sexp[0..-2]
      @code = Sorcerer.source(before_sexp)
      eval(@code)
    end

    def before_assertion_block
      eval("proc { #{@code} }")
    end
    
  end
end
