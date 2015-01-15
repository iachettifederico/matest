require 'term/ansicolor'

module Matest
  module Color
    module_function

    Term::ANSIColor.attributes.each do |attr|
      define_method(attr) do |str|
        Matest::Configure.color? ? Term::ANSIColor.send(attr, str) : str
      end
    end
  end
end
