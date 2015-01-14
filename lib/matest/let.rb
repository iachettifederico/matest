module Matest
  class Let
    attr_reader :var_name
    attr_reader :block
    attr_reader :bang

    def initialize(var_name, block, bang=false)
      @var_name = var_name
      @block = block
      @bang = bang
    end
  end
end
