class PackratParser
  class Result
  end

  class Parsed < Result
    attr_reader :value, :remainder

    def initialize(value, remainder)
      @value = value
      @remainder = remainder
    end

    def succeeded?
      true
    end
  end

  NO_PARSE = Result.new

  def NO_PARSE.succeeded?
    false
  end

  class ParseError < StandardError; end

  class Derivs
    def initialize(parser, str)
      @parser = parser
      @str = str
      @memo = {}
    end

    def char
      if @str.empty?
        NO_PARSE
      else
        Parsed.new(@str[0], Derivs.new(@parser, @str[1..-1]))
      end
    end

    def method_missing(mid, *args)
      @memo[mid] ||= @parser.parser(mid).parse(self)
    end
  end

  class Parser
    def initialize(&block)
      @block = block
    end

    def parse(d)
      @block.call(d)
    end

    def bind(&f2)
      p1 = self
      Parser.new { |d|
        result = p1.parse(d)
        if result.succeeded?
          p2 = f2.call(result.value)
          p2.parse(result.remainder)
        else
          NO_PARSE
        end
      }
    end

    def /(p2)
      p1 = self
      Parser.new { |d|
        result = p1.parse(d)
        if result.succeeded?
          result
        else
          p2.parse(d)
        end
      }
    end
  end

  def initialize(start_symbol, &block)
    @parsers = {}
    @start_symbol = start_symbol
    instance_exec(&block) if block
  end

  def parse(str)
    result = Derivs.new(self, str).send(@start_symbol)
    if result == NO_PARSE
      raise ParseError, "parse error"
    end
    result.value
  end

  def define(sym, parser)
    @parsers[sym] = parser
  end

  def parser(sym)
    @parsers[sym]
  end

  def ret(value)
    Parser.new { |d|
      Parsed.new(value, d)
    }
  end

  def no_parse
    Parser.new { |d|
      NO_PARSE
    }
  end

  def method_missing(mid, *args)
    Parser.new(&mid)
  end

  def any_char
    Parser.new(&:char)
  end

  def char(ch)
    any_char.bind { |c|
      if c == ch
        ret c
      else
        no_parse
      end
    }
  end
end
