require "spec_helper"

scope do
  xspec "it explains local variables on failure" do
    a = 5
    b = 6

    a + b == 10
  end

  xspec "it explains local variables on non natural" do
    a = 5
    b = 6

    a + rand(b)
  end

  let(:b) { 1 }
  xspec "still works with lets" do
    a = 1

    a + b == 3
  end
end
