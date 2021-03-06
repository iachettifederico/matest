require "spec_helper"

scope do
  let(:m1) { :m1 }
  let!(:m3) { :m3 }

  let(:m4) { :m4 }
  let!(:m5) { :m5 }

  spec do
    m1 == :m1
  end
  #
  spec do
    ! defined?(m2)
  end

  spec do
    m3 == :m3
  end

  spec do
    ! defined?(@m4)
  end

  spec do
    !! defined?(@m5)
  end

  scope do
    let(:m2) { :m2 }
    spec do
      m1 == :m1
    end

    spec do
      m2 == :m2
    end
  end
end

scope do
  @c = true
  test do
    @a = true
    !defined?(@b)
  end

  test do
    @b = true
    !defined?(@a)
  end

  test do
    !defined?(@c)
  end
end
