require "spec_helper"

scope do
  spec "it explains local variables on failure" do
    a = 5
    b = 6

    a + b == 10
  end

  spec "it explains local variables on non natural" do
    a = 5
    b = 6

    a + rand(b)
  end
end
