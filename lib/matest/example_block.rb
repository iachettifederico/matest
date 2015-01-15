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
    lineno = block.source_location.last

    current_line = lineno-1
    valid_lines = [lines[current_line]]

    until Ripper::SexpBuilder.new(valid_lines.join("\n")).parse
      current_line += 1
      valid_lines << lines[current_line]
    end

    valid_lines[1..-2].join
  end

  def lines
    @lines ||= get_lines
  end

  def get_lines
    file = File.open(block.source_location.first)
    source = file.read
    source.each_line.to_a
  end
end
