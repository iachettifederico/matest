module Matest
  def self.configure(&block)
    block.call(Configure) if block_given?
  end
  
  
  module Configure
    module_function

    def use_color?
      @use_color ||= false
    end

    def use_color=(use_color)
      @use_color = use_color
    end
  end
end
