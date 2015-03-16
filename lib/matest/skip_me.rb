module Matest
  class SkipMe
    attr_reader :source_location
    def initialize(the_caller=nil)
      if the_caller
        @the_caller = the_caller
        file, lineno = the_caller.first.split(":")
        @source_location = [file, lineno.to_i]
      end
    end

    def to_proc
      proc { SkipMe.new }
    end
  end
end
