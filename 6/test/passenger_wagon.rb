#!/usr/bin/ruby -w

require_relative '../passenger_wagon.rb'

# test # test # test # test # test # test # test # test # test # test # test

# пока классы не созданы, делаем пустые заглушки для теста
class Train; end
class PassengerTrain < Train; end

pw = PassengerWagon.new
puts "pw.hookable? PassengerTrain => #{pw.hookable? PassengerTrain}"
puts "pw.hookable? Train => #{pw.hookable? Train}"
puts "Тип вагона: #{pw.class.type_name}, id: #{pw.id}"
p pw
begin
  print 'пробуем вызвать protected'
  pw.types
  puts ' [ERROR!]'
rescue NoMethodError
  puts ' [ОК]'
end

puts pw.manufacturer
pw.manufacturer = 'Simens'
puts pw.manufacturer

p Wagon.descendants.map(&:type_name)
