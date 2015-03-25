require "spec_helper"


scope do
  spec "pass" do
    :pre
  end

  spec do
    # @runner = Matest::Runner.runner
    # @scope = @runner.example_groups.first
    # @scope_block = @scope.scope_block
    # @scope.specs[1].example_block.from_line
    # @scope.specs[1].example_block.to_line
    true
  end

  spec "passss" do
    :post
  end


end
