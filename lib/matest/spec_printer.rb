require "matest/evaluator"

module Matest
  class SpecPrinter
    def print(res)
      super res
    end
    
    def print_messages(runner)
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
              puts "Explanation:"
              subexpressions = Sorcerer.subexpressions(status.example.example_block.assertion_sexp).reverse.uniq.reverse
              subexpressions.each do |code|
                print_subexpression(code, status)
              end
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
      just_before_assertion = status.example.just_before_assertion
      result = Evaluator.new(just_before_assertion, just_before_assertion.before_assertion_block).eval_string(code)
      if result.class != Matest::EvalErr
        puts <<-CODE
  #{code}
    # => #{result}
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
