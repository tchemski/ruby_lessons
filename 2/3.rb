#!/usr/bin/ruby -w

# Заполнить массив числами фибоначчи до 100

fib = [ 0, 1 ]
limit = 100

loop do
  next_fib = fib[-1] + fib[-2]
  break if next_fib > limit
  fib.push next_fib
end

p fib
