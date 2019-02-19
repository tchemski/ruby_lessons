#!/usr/bin/ruby -w

require_relative '../route.rb'

# test# test# test# test# test# test# test# test# test# test# test# test# test
# test# test# test# test# test# test# test# test# test# test# test# test# test
if $PROGRAM_NAME == __FILE__
  station = Station.new('Минск-Пассажирский')
  station2 = Station.new('Молодечно')

  train = PassengerTrain.new

  route = Route.new(station, station2)

  begin
    print 'Не даём создать маршрут из менее 2-х станций '
    Route.new(station)
    puts '[ERROR!]'
  rescue RuntimeError
    puts '[ОК]'
  end

  begin
    print 'Не даём создать маршрут c повторяющимися станциями '
    Route.new(station, station2, station)
    puts ' [ERROR!]'
  rescue RuntimeError
    puts ' [ОК]'
  end

  begin
    print 'Не даём вставить станцию после конечной '
    route.insert_stations_after(station2, Station.new('qwerty'))
    puts '[ERROR!]'
  rescue RuntimeError
    puts '[ОК]'
  end

  route.insert_stations_after(station, Station.new('Минск-Северный'))

  station.take_train train
  begin
    print 'Не даём принять поезд который уже на станции '
    station.take_train train
    puts '[ERROR!]'
  rescue RuntimeError
    puts '[ОК]'
  end

  begin
    print 'Не даём отправить поезд которого на станции нет '
    station.send_train Train.new
    puts '[ERROR!]'
  rescue RuntimeError
    puts '[ОК]'
  end
  puts "    station.name:#{station.name}"
  puts "    route.stations:#{route.stations}"
  puts "    train.id:#{train.id}"

  station.send_train train

  severniy = route.stations[1]
  route.insert_stations_after(
    severniy, Station.new('Масюковщина'), Station.new('Лебяжий'),
    Station.new('Ждановичи'), Station.new('Минское Море'),
    Station.new('Ратомка'), Station.new('Крыжовка'),
    Station.new('Зелёное'), Station.new('Беларусь')
  )
  train.route = route

  loop do
    puts station
    break unless train.next_station

    train.move_forward
  end

  route.delete_stations severniy
  puts 'Удалили станцию'

  loop do
    puts station
    break unless train.prev_station

    train.move_backward
  end

  print 'Попытка удалить несуществующую станцию '
  begin
    route.delete_stations severniy
    puts '[ERROR!]'
  rescue RuntimeError
    puts ' [OK]'
  end

  10.times { train.hook_wagon PassengerWagon.new }
  puts train
  print 'Проверка отсоединения вагонов '
  begin
    11.times { train.unhook_wagon }
    puts '[ERROR!]'
  rescue RuntimeError
    puts ' [OK]'
  end

  puts train
  train.speed = 100
  puts train

  begin
    print 'Не даём установить отрицательную скорость '
    train.speed = -1
    puts '[ERROR!]'
  rescue RuntimeError
    puts '[ОК]'
  end
  puts train
  train.stop
  puts train

  puts 'добавим разных поездов на станцию'
  station.take_train PassengerTrain.new('23143')
  station.take_train PassengerTrain.new('asd-12')
  station.take_train PassengerTrain.new
  station.take_train PassengerTrain.new
  station.take_train CargoTrain.new
  station.take_train CargoTrain.new
  station.take_train CargoTrain.new
  puts '====Пассажирские поезда===='
  station.trains(PassengerTrain).each { |t| puts t }
  puts '====Товарные поезда===='
  station.trains(CargoTrain).each { |t| puts t }
  puts '====Все поезда===='
  station.trains.each { |t| puts t }

  puts Train.all

  puts Train.find('asd-12')

  puts Train.instances

  begin
    print 'Не даём создать поезд с уже занятым номером'
    CargoTrain.new('asd-12')
    puts '[ERROR!]'
  rescue RuntimeError
    puts '[ОК]'
  end

  begin
    print 'Не даём создать маршрут с одной станцией'
    Route.new station
    puts '[ERROR!]'
  rescue RuntimeError
    puts '[ОК]'
  end

  begin
    print 'Не даём создать маршрут без станций'
    Route.new
    puts '[ERROR!]'
  rescue ArgumentError
    puts '[ОК]'
  end

  begin
    print 'Не даём создать маршрут из всякой фигни'
    Route.new 'Привет', 'Как дела?'
    puts '[ERROR!]'
  rescue RuntimeError
    puts '[ОК]'
  end

  pass_train = PassengerTrain.new
  cargo_train = CargoTrain.new

  5.times { pass_train.hook_wagon PassengerWagon.new }
  5.times { cargo_train.hook_wagon CargoWagon.new }
  ###########################################################################
  puts 'Test Train#wagons.each'
  pass_train.wagons.each do |w|
    8.times { w.take_seat }
    puts w
  end
  cargo_train.wagons.each do |w|
    w.load(rand(w.max_vol * 10) / 10.0)
    puts w
  end

  puts 'Test Station#trains.each_train'
  station.trains.each { |t| puts t }
end
