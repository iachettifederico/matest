module Matest
  def self.configure(&block)
    block.call(Configure) if block_given?
  end
  
  
  module Configure
    module_function

    def color?
      @color ||= false
    end

    def color=(color)
      @color = color
    end

    def use_color
      @color = true
    end
  end
end
