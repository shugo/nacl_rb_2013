require_relative "arith_recurse"

p ArithRecurse.new.eval("1+(2*(3+(4*(5+(6*(7+(8+9)))))))")
