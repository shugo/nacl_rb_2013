require "haensel"

g = Haensel::Grammar.new(:odd_evens) {
  define :odd_evens,
    odd_even.bind { |x|
      odd_evens.bind { |y|
        ret x + y
      }
    } /
    odd_even

  define :odd_even,
    odd.bind { |x| even.bind { |y| ret x + y } }

  define :odd, any_char.bind { |x| x.odd? ? ret(x) : fail }

  define :even, any_char.bind { |x| x.even? ? ret(x) : fail }
}
p g.parse([1, 2, 3, 4])
p g.parse([31, 64, 27, 82, 777, 666])
p g.parse([1, 3, 5, 7])
