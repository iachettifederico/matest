require "ripper"
require "sorcerer"

class ExampleBlock
  attr_reader :block
  attr_reader :code
  attr_reader :sexp
  attr_reader :assertion
  attr_reader :assertion_sexp

  def initialize(block)
    @block = block

    @code = generate_code

    @sexp = Ripper::SexpBuilder.new(code).parse.last
    @assertion_sexp = @sexp.last
    @assertion = Sorcerer.source(assertion_sexp)
  end

  def call
    block.call
  end

  def source_location
    block.source_location
  end

  private

  def generate_code
    file = File.open(block.source_location.first)
    source = file.read
    lines = source.each_line.to_a

    lineno = block.source_location.last

    current_line = lineno-1
    valid_lines = [lines[current_line]]

    valid_lines

    until Ripper::SexpBuilder.new(valid_lines.join("\n")).parse
      current_line += 1
      valid_lines << lines[current_line]
    end
    code_array = valid_lines[1..-2]
    code_array.join
  end
end
