#!/usr/bin/ruby -w

# как работает флаг -w
class Test
  def send; end

  def __send__; end
end
