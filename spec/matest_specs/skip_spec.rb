require "spec_helper"

scope do
  spec do
    true
  end

  xspec do
    true
  end

  spec "Skip!!"
end

xscope do
  spec do
    true
  end

  xspec do
    true
  end

  spec "Skip!!"
end

