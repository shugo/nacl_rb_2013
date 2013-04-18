require_relative "arith_monad"

p ArithMonad.new.eval("1+2")
p ArithMonad.new.eval("2*3")
p ArithMonad.new.eval("2*(3+4)")
p ArithMonad.new.eval("(2+3)*4")
p ArithMonad.new.eval("1+(2*(3+(4*(5+(6*(7+(8+9)))))))")
