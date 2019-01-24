#!/usr/bin/ruby -w

class Station

  #Имеет название
  attr_reader :name

  #название указывается при ее создании
  def initialize( name )
    @name = name
    @trains = []
  end

  #Может принимать поезда (по одному за раз)
  def take( train )
    raise "этот поезд уже на станции" if include? train
    @trains << train
  end

  #Может отправлять поезда
  #(по одному за раз, при этом, поезд удаляется из списка поездов, находящихся на станции).
  def send( train )
    @trains.delete( train )|| raise( "такого поезда на этой станции нет")
  end

  def include?( train )
    @trains.include? train
  end

  #Может возвращать список поездов на станции по типу
  #Может возвращать список всех поездов на станции, находящиеся в текущий момент
  def trains(type = nil)
    unless type
      return @trains
    else
      return @trains.map{|train| train.type == type}
    end
  end

  #кол-во грузовых, пассажирских
  def trains_number(type = nil)
    unless type
      return @trains.size
    else
      return @trains.count{|train| train.type == type}
    end
  end

end

class Train

  #Может возвращать текущую скорость, станцию, маршрут
  attr_reader :station, :route, :speed

  PASSANGER = 1
  FREIGHT = 2

  #тип (грузовой, пассажирский)
  #количество вагонов, эти данные указываются при создании экземпляра класса
  def initialize( info = {type: PASSANGER, wagons_umber: 0} )
    @info = info
    @speed = 0
  end

  # Возвращать предыдущую станцию, текущую, следующую, на основе маршрута
  # возвращает nil если станция конечная (или лучше бросать исключение?)
  def next_station
    stations = @route.stations
    station_index = stations.index @station
    stations[station_index + 1]
  end

  def prev_station
    stations = @route.stations
    station_index = stations.index @station
    station_index == 0 ? nil : stations[station_index - 1]
  end

  def move_forward
    #next_station ? @station = next_station : raise( "конечная, поезд дальше не идёт" )
    if next_station
      @station.send self #отправили
      next_station.take self #приняли
      @station = next_station #записали
    else
      raise( "конечная, поезд дальше не идёт" )
    end
  end

  #Может перемещаться между станциями, указанными в маршруте.
  #Перемещение возможно вперед и назад, но только на 1 станцию за раз.
  #(непонятно как этот метод согласуется со скоростью, мгновенные перемещения?)
  def move_backward
    if prev_station
      @station.send self #отправили
      prev_station.take self
      @station = prev_station
    else
      raise( "конечная, поезд дальше не идёт" )
    end
  end

  # Может набирать скорость
  def speed=( speed )
    raise "скорость не может быть меньше нуля speed = #{speed }" unless speed < 0
    # TODO по идее надо ещё максимальную скорость проверить, зависит от типа поезда
    #      и маршрута, но в условии задачи этого нет
    @speed = speed
  end

  # Может тормозить (сбрасывать скорость до нуля)
  def stop
    self.speed = 0
  end

  # Может прицеплять (метод просто увеличивает или уменьшает количество вагонов).
  def hook_wagon
    #Прицепка/отцепка вагонов может осуществляться только если поезд не движется.
    raise "нельзя цеплять вагон к движещемуся поезду" if speed > 0
    # TODO проверка на максимальную длинну
    @info[:wagons_number] += 1
  end

  # отцеплять вагоны (по одному вагону за операцию)
  def unhook_wagon
    #Прицепка/отцепка вагонов может осуществляться только если поезд не движется.
    raise "нельзя отцеплять вагон к от движещегося поезда" if speed > 0
    raise "нельзя отцепить вагон которого не существует" if @wagons_number == 0
    @info[:wagons_number] -= 1
  end

  #При назначении маршрута поезду, поезд автоматически помещается на первую станцию в маршруте.
  #(сомнительная операция, поезд находится на некой станции, ему дали маршрут - оп,
  #  поезд на другой станции, скорость света превышена)
  #Может принимать маршрут следования (объект класса Route).
  def route=( route )
    @route = route
    @station = route.begin_station
    @station.take self
  end

  #Имеет номер (произвольная строка)
  def id
    self.object_id
  end

  def type
    @info[:type]
  end

  #Может возвращать количество вагонов
  def wagons_number
    @info[:wagons_number]
  end

end

class Route

  #Имеет начальную и конечную станцию, а также список промежуточных станций
  #Может выводить список всех станций по-порядку от начальной до конечной
  attr_reader :stations

  #Начальная и конечная станции указываютсся при создании маршрута
  #промежуточные могут добавляться между ними
  def initialize( begin_station, *stations )
    # begin_station здесь для лучшего документирования, можно было обойтись просто
    # *stations, но тогда непонятно где начало и где конец

    #начало и конец маршрута
    @stations = [ begin_station ]
    end_station = stations.pop || raise("нельзя создать маршрут менее чем из двух станций")
    raise "такая станция уже есть на маршруте" if begin_station == end_station
    @stations << end_station

    #остальные станции вставляем между
    insert_stations_after begin_station, *stations
    @stations
  end

  #Может добавлять промежуточную станцию в список
  def insert_stations_after( current, *stations)
    if current == end_station()
      raise "нельзя добавлять станции после конечной, создайте новый маршрут"
    end

    station_index = @stations.index(current)
    stations.each do |station|
      raise "такая станция уже есть на маршруте" if include? station
      @stations.insert(station_index += 1, station)
    end
    stations
  end

  #Может удалять промежуточную станцию из списка
  def delete_stations( *stations )
    stations.each do |station|
      if station == begin_station() || station == end_station()
        raise "нельзя удалять начальную и конечную станцию маршрута"
      end
      @stations.delete station
    end
    stations
  end

  def begin_station
    @stations[0]
  end

  def end_station
    @stations[-1]
  end

  def include?( station )
    @stations.include?( station )
  end
end

# test# test# test# test# test# test# test# test# test# test# test# test# test
# test# test# test# test# test# test# test# test# test# test# test# test# test
if $0 == __FILE__
  station = Station.new('Минск-Пассажирский')
  station2 = Station.new('Молодечно')

  train = Train.new
  train2 = Train.new( type: Train::PASSANGER, wagons_umber: 5 )

  route = Route.new(station, station2)

  begin
    print "Не даём создать маршрут из менее 2-х станций "
    Route.new(station)
    puts "[ERROR!]"
  rescue RuntimeError
    puts "[ОК]"
  end

  begin
    print "Не даём создать маршрут c повторяющимися станциями "
    Route.new(station, station2, station)
    puts " [ERROR!]"
  rescue RuntimeError
    puts " [ОК]"
  end

  begin
    print "Не даём вставить станцию после конечной "
    route.insert_stations_after(station2, Station.new('qwerty'))
    puts "[ERROR!]"
  rescue RuntimeError
    puts "[ОК]"
  end

  route.insert_stations_after(station, Station.new('Минск-Северный'))

  station.take train
  begin
    print "Не даём принять поезд который уже на станции "
    station.take train
    puts "[ERROR!]"
  rescue RuntimeError
    puts "[ОК]"
  end

  begin
    print "Не даём отправить поезд которого на станции нет "
    station.send Train.new
    puts "[ERROR!]"
  rescue RuntimeError
    puts "[ОК]"
  end
  puts "    station.name:#{station.name}"
  puts "    route.stations:#{route.stations}"
  puts "    train.id:#{train.id}"
  p station
  p train
  p train2
  p route

  station.send train
  p station

  severniy = route.stations[1]
  route.insert_stations_after(severniy, Station.new('Масюковщина'), Station.new('Лебяжий'),
                                Station.new('Ждановичи'), Station.new('Минское Море'),
                                Station.new('Ратомка'), Station.new('Крыжовка'),
                                Station.new('Зелёное'), Station.new('Беларусь') )
  train.route = route

  loop do
    p train.station.name
    break unless train.next_station
    train.move_forward
  end

end
