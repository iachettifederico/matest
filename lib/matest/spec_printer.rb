module Matest

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

          if status.is_a?(Matest::SpecPassed)
          else
            if status.is_a?(Matest::SpecFailed)
              runner.info[:success] = false
            end
            puts "\n[#{status.name}] #{status.description}"
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
            puts "  #{status.location}:"
          end
        end
      end
    end
  end
end
