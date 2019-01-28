#!/usr/bin/ruby -w

require_relative 'wagon.rb'
class PassengerWagon < Wagon
  def type_name
    'пассажирский'
  end

  protected

  def types
    [PassengerTrain]
  end
end

# test # test # test # test # test # test # test # test # test # test # test
if $0 == __FILE__
  # пока классы не созданы, делаем пустые заглушки для теста
  class Train; end
  class PassengerTrain < Train; end

  pw = PassengerWagon.new
  puts "pw.hookable? PassengerTrain => #{pw.hookable? PassengerTrain}"
  puts "pw.hookable? Train => #{pw.hookable? Train}"
  puts "Тип вагона: #{pw.type_name}, id: #{pw.id}"
  p pw
  begin
    print 'пробуем вызвать protected'
    pw.types
    puts ' [ERROR!]'
  rescue NoMethodError
    puts ' [ОК]'
  end
end
