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

    @code =  generate_code
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
  def parse_valid_lines
    assertion_sexp = Ripper::SexpBuilder.new(valid_lines).parse.last.last
    if assertion_sexp.first == :var_ref
      assertion_sexp.last
    else
      assertion_sexp
    end
  end
  
  def generate_code
    code = parse_valid_lines
    Sorcerer.source(code)
  rescue Sorcerer::Resource::NotSexpError => e
    "Matest::SkipMe.new"
  rescue NoMethodError => e

    if e.message == "undefined method `last' for :void_stmt:Symbol"
      return "nil"
    else
      raise e
    end
  end

  def lines
    @lines ||= get_lines
  end

  def get_lines
    file = File.open(block.source_location.first)
    source = file.read
    source.each_line.to_a
  end

  def valid_lines
    lineno = block.source_location.last

    current_line = lineno-1
    valid_lines = [lines[current_line]]

    until Ripper::SexpBuilder.new(valid_lines.join("\n")).parse
      current_line += 1
      valid_lines << lines[current_line]
    end

    code = valid_lines[1..-2].join

    return code unless code == ""

    valid_lines = [lines[lineno-1]].join
  end
end
