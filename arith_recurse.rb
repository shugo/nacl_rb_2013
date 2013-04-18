class ArithRecurse
  Parsed = Struct.new(:value, :remainder)
  class ParseError < StandardError; end

  def eval(s)
    if x = p_additive(s)
      x.value
    else
      raise ParseError
    end
  end

  private

  def p_additive(s)
    p [:p_additive, s] if $DEBUG
    if (x = p_multitive(s)) &&
      x.remainder[0] == ?+ &&
      (y = p_additive(x.remainder[1..-1]))
      Parsed.new(x.value + y.value, y.remainder)
    else
      p_multitive(s)
    end
  end

  def p_multitive(s)
    p [:p_multitive, s] if $DEBUG
    if (x = p_primary(s)) &&
      x.remainder[0] == ?* &&
      (y = p_additive(x.remainder[1..-1]))
      Parsed.new(x.value * y.value, y.remainder)
    else
      p_primary(s)
    end
  end

  def p_primary(s)
    p [:p_primary, s] if $DEBUG
    if s[0] == ?( &&
      (x = p_additive(s[1..-1])) &&
      x.remainder[0] == ?)
      Parsed.new(x.value, x.remainder[1..-1])
    else
      p_decimal(s)
    end
  end

  def p_decimal(s)
    p [:p_decimal, s] if $DEBUG
    if m = /\A\d+/.match(s)
      Parsed.new(m[0].to_i, m.post_match)
    else
      nil
    end
  end
end
