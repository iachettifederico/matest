module Matest
  class EvalErr
    def initialize(str)
      @string = str
    end
    def size
      inspect.size
    end
    def to_s
      @string
    end
    def inspect
      @string
    end
  end

  class Evaluator
    def initialize(example, block)
      # @example = Marshal.load( Marshal.dump(example) )
      @example = example
      @block = block
    end

    def eval_string(exp_string)
      limit_length(eval_in_context(exp_string).inspect)
    rescue StandardError => ex
      EvalErr.new("#{ex.class}: #{ex.message}")
    end

    private

    MAX_INSPECT_SIZE = 2000

    def limit_length(string)
      if string.size > MAX_INSPECT_SIZE
        string[0..MAX_INSPECT_SIZE] + " (...truncated...)"
      else
        string
      end
    end

    def eval_in_context(exp_string)
      exp_proc = "proc { #{exp_string} }"
      blk = eval(exp_proc, @block.binding)
      @example.instance_eval(&blk)
    end
  end

  class SpecPrinter
    def print(runner)
      puts "\n\n### Messages ###"

      statuses = []
      runner.info[:success] = true
      runner.info[:num_specs] = { total: 0 }

      runner.example_groups.each do |current_group|
        current_group.statuses.each do |status|
          runner.info[:num_specs][:total] += 1

          runner.info[:num_specs][status.name] ||= 0
          runner.info[:num_specs][status.name] += 1

          if !status.is_a?(Matest::SpecPassed)
            puts "\n[#{status.name}] #{status.description}"
            puts "Location:\n  #{status.location}:"

            if status.is_a?(Matest::SpecFailed)
              runner.info[:success] = false
              puts "Assertion: \n  #{status.example.example_block.assertion}"
              puts "Variables: "
              status.example.track_variables.each do |var, val|
                puts "  #{var}: #{val.inspect}"
              end
              puts "Lets: "
              status.example.track_lets.each do |var, val|
                puts "  #{var}: #{val.inspect}"
              end

              puts "Explanation:"
              subexpressions = Sorcerer.subexpressions(status.example.example_block.assertion_sexp).reverse.uniq.reverse
              subexpressions.each do |code|
                print_subexpression(code, status)
              end
            end
            if status.is_a?(Matest::NotANaturalAssertion)
              runner.info[:success] = false
              puts "  # => #{status.result.inspect}"
            end
            if status.is_a?(Matest::ExceptionRaised)
              runner.info[:success] = false
              puts "EXCEPTION >> #{status.result}"
              status.result.backtrace.each do |l|
                puts "  #{l}"
              end

            end
          end
        end
      end
    end

    def print_subexpression(code, status)
      result = Evaluator.new(status.example, status.example.example_block.block).eval_string(code)
      if result.class != Matest::EvalErr
        puts <<-CODE
  "#{code}" =>
    #{result}
      CODE
      else
        puts <<-CODE
  The assertion couldn't be explained.
  The error message was: 
    #{result}
  Make sure you are not calling any local vaiables on your code assertion.
      CODE
      end
    end
  end
end
