require "spec_helper"

scope do
  spec { true }
  xspec { false }

  example { true }
  xexample { false }

  it { true }
  xit { false }
end

describe do
  spec { true }
  xspec { false }

  example { true }
  xexample { false }

  it { true }
  xit { false }
end

context do
  spec { true }
  xspec { false }

  example { true }
  xexample { false }

  it { true }
  xit { false }
end

xscope do
  spec { true }
  xspec { false }

  example { true }
  xexample { false }

  it { true }
  xit { false }
end

xdescribe do
  spec { true }
  xspec { false }

  example { true }
  xexample { false }

  it { true }
  xit { false }
end

xcontext do
  spec { true }
  xspec { false }

  example { true }
  xexample { false }

  it { true }
  xit { false }
end
