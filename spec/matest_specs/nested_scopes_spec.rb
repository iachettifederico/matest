require "spec_helper"

scope "A" do
  spec "A.0" do
    false
  end

  spec "A.1" do
    false
  end

  scope "B" do
    spec "B.0" do
      false
    end

    scope "C" do
      spec "C.0" do
        false
      end
    end

    spec "B.1" do
      false
    end
  end
end
