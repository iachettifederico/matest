module Matest
  class SpecStatus
    attr_reader :example
    attr_reader :result

    def initialize(example, result, description=nil)
      @example = example
      @result = result
    end

    def location
      "%s:%d" % example.example_block.source_location
    end

    def description
      example.description
    end

    def name
      self.class.name
    end
    
    def self.to_s
      name
    end
  end

  class SpecPassed < SpecStatus
    def to_s
      "."
    end

    def self.name
      "PASSING"
    end
  end

  class SpecFailed < SpecStatus
    def to_s
      "F"
    end

    def self.name
      "FAILING"
    end
  end

  class SpecSkipped < SpecStatus
    def to_s
      "S"
    end

    def self.name
      "SKIPPED"
    end
  end
  class NotANaturalAssertion < SpecStatus
    def to_s
      "N"
    end

    def self.name
      "NOT A NATURAL ASSERTION"
    end
  end

  class ExceptionRaised < SpecStatus
    attr_reader :exception
    def to_s
      "E"
    end

    def self.name
      "ERROR"
    end
  end
end
