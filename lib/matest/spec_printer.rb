require "matest/evaluator"

module Matest
  class SpecPrinter
    include Color

    def prints(res)
      print send(colors[res.class], res.to_s)
    end

    def print_messages(runner)
      puts header("\n\n### Messages ###")

      statuses = []
      runner.info[:success] = true
      runner.info[:num_specs] = { total: 0 }

      runner.example_groups.each do |current_group|
        current_group.statuses.each do |status|
          runner.info[:num_specs][:total] += 1

          runner.info[:num_specs][status.name] ||= 0
          runner.info[:num_specs][status.name] += 1

          if !status.is_a?(Matest::SpecPassed)
            puts send(colors[status.class], "\n[#{status.name}] #{status.description}")
            puts header("Location")
            puts " #{status.location}:"

            if status.is_a?(Matest::SpecFailed)
              runner.info[:success] = false
              puts header("Assertion")
              puts expression("  #{status.example.example_block.assertion}")
              if status.example.track_variables.any?
                puts header("Variables")
                status.example.track_variables.each do |var, val|
                  puts key_value(var, val)
                end
              end
              if status.example.track_lets.any?
                puts header("Lets")
                status.example.track_lets.each do |var, val|
                  puts key_value(var, val)
                end
              end

              print_explanation_for(status)
            end
            if status.is_a?(Matest::NotANaturalAssertion)
              runner.info[:success] = false
              puts "  # => #{status.result.inspect}", reset("")
              print_explanation_for(status)
            end
            if status.is_a?(Matest::ExceptionRaised)
              runner.info[:success] = false
              puts error("EXCEPTION >> #{status.result}")
              status.result.backtrace.each do |l|
                puts error("  #{l}")
              end
            end
          end
        end
      end
      puts nil, "-"*50, nil
      puts "Specs:"

      #p runner.info
      runner.info[:num_specs].each { |name, num|
        puts "  #{num} #{name.downcase}."
      }


    end

    def print_explanation_for(status)
      subexpressions = Sorcerer.subexpressions(status.example.example_block.assertion_sexp).reverse.uniq.reverse
      if subexpressions.any?
        puts header("Explanation")
        subexpressions.all? do |code|
          print_subexpression(code, status)
        end
      end
    end

    def print_subexpression(code, status)
      just_before_assertion = status.example.just_before_assertion
      result = Evaluator.new(just_before_assertion, just_before_assertion.before_assertion_block).eval_string(code)
      if result.class != Matest::EvalErr
        explanation = []
        explanation << expression("  #{code}")
        explanation << "\n"
        explanation << value("    # => #{result}")
        puts explanation.join
        true
      else
        code = <<-CODE
  The assertion couldn't be explained.
  The error message was:
    #{result}
  Make sure you are not calling any local vaiables on your code assertion.
      CODE
        puts error(code)
        false
      end
    end

    private

    def header(str)
      white(str + ":")
    end

    def expression(str)
      yellow(str)
    end

    def value(str)
      blue(str)
    end

    def key_value(key, value)
      "  #{yellow(key.to_s)} #{bright_black("=>")} #{blue(value.inspect)}#{reset("")}"
    end

    def error(str)
      red(str)
    end

    def colors
      {
       Matest::SpecPassed           => :green,
       Matest::SpecFailed           => :red,
       Matest::SpecSkipped          => :yellow,
       Matest::NotANaturalAssertion => :cyan,
       Matest::ExceptionRaised      => :magenta,
      }
    end
  end
end
