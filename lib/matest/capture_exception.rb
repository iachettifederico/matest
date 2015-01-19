module Matest
  class NoExceptionRaised < RuntimeError; end
  class UnexpectedExceptionRaised < RuntimeError; end

  def capture_exception(exception_class=nil, &block)
    expected_exception = exception_class || BasicObject
    begin
      block.call
      if exception_class
        raise Matest::NoExceptionRaised.new("Expected '#{exception_class.inspect}' from the block, but none was raised.")
      else
        raise Matest::NoExceptionRaised.new("Expected an Exception from the block, but none was raised.")
      end
      false
    rescue Matest::NoExceptionRaised => e
      raise e
    rescue expected_exception => e
      e
    rescue BasicObject => e
      raise e
    end
  end
end
