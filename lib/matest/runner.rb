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
      example_group.printer = printer
      example_groups << example_group
    end

    def load_file(file)
      location = file.split(":")
      if location.count == 1
        require(file)
      else
        require_spec(*location)
      end
    end

    def execute!
      example_groups.each do |current_group|
        current_group.execute!
      end
      printer.print_messages(self)
    end

    private

    def require_spec(file, line)
      require file
    end
  end

end
