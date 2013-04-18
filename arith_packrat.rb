require "immutable"

class ArithPackrat
  include Immutable

  Parsed = Struct.new(:value, :remainder)

  class ParseError < StandardError; end

  class Derivs
    def initialize(attrs)
      @attrs = attrs
    end

    [:additive, :multitive, :primary, :decimal, :char].each do |m|
      define_method(m) {
        @attrs[m]
      }
    end
  end

  def eval(s)
    parse(s).force.additive.force.value
  end

  def parse(s)
    Promise.lazy {
      d = Promise.delay {
        Derivs.new(additive: p_additive(d),
                   multitive: p_multitive(d),
                   primary: p_primary(d),
                   decimal: p_decimal(d),
                   char: Promise.delay { s.empty? ? nil : Parsed.new(s[0], parse(s[1..-1])) })
      }
    }
  end

  private

  def p_additive(d)
    Promise.lazy {
      if (x = d.force.multitive.force) &&
        (c = x.remainder.force.char.force) && c.value == ?+ &&
        (y = c.remainder.force.additive.force)
        Promise.delay { Parsed.new(x.value + y.value, y.remainder) }
      else
        d.force.multitive
      end
    }
  end

  def p_multitive(d)
    Promise.lazy {
      if (x = d.force.primary.force) &&
        (c = x.remainder.force.char.force) && c.value == ?* &&
        (y = c.remainder.force.multitive.force)
        Promise.delay { Parsed.new(x.value * y.value, y.remainder) }
      else
        d.force.primary
      end
    }
  end

  def p_primary(d)
    Promise.lazy {
      if (c = d.force.char.force) && c.value == ?( &&
        (x = c.remainder.force.additive.force) &&
        (c2 = x.remainder.force.char.force) && c2.value == ?)
        Promise.delay { Parsed.new(x.value, c2.remainder) }
      else
        d.force.decimal
      end
    }
  end

  def p_decimal(d)
    Promise.lazy {
      if (c = d.force.char.force) &&
        /\d/.match(c.value)
        Promise.delay { Parsed.new(c.value.to_i, c.remainder) }
      else
        Promise.eager(nil)
      end
    }
  end
end
