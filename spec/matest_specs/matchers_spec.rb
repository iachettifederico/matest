require "spec_helper"

def is_even?(val)
  val % 2 == 0
end
scope do
  spec do
    is_even?(4)
  end

  spec do
    ! is_even?(5)
  end
end
