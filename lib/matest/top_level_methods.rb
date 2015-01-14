def scope(description=nil, &block)
  Matest::Runner.runner << Matest::ExampleGroup.new(block)
end

def xscope(description=nil, &block)
  # no-op
end

alias :describe :scope
alias :xdescribe :xscope

alias :context :scope
alias :xcontext :xscope

alias :group :scope
alias :xgroup :xscope
