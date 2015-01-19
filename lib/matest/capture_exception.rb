class NoExceptionRaised < RuntimeError; end
class UnexpectedExceptionRaised < RuntimeError; end

def capture_exception(exception_class=BasicObject, &block)
  begin
    block.call
    raise NoExceptionRaised.new
    false
  rescue exception_class => e
    e
  rescue BasicObject => e
    raise UnexpectedExceptionRaised.new
  end
end
