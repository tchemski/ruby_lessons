#!/usr/bin/ruby -w

class Station
=begin
+Имеет название, которое указывается при ее создании
Может принимать поезда (по одному за раз)
Может возвращать список всех поездов на станции, находящиеся в текущий момент
Может возвращать список поездов на станции по типу (см. ниже): кол-во грузовых, пассажирских
Может отправлять поезда (по одному за раз, при этом, поезд удаляется из списка поездов, находящихся на станции).
=end


  attr_reader :name

  def initialize( name )
    @name = name
  end

  def take( train )

  end



end

class Train
=begin
Имеет номер (произвольная строка) и тип (грузовой, пассажирский) и количество вагонов, эти данные указываются при создании экземпляра класса
Может набирать скорость
Может возвращать текущую скорость
Может тормозить (сбрасывать скорость до нуля)
Может возвращать количество вагонов
Может прицеплять/отцеплять вагоны (по одному вагону за операцию, метод просто увеличивает или уменьшает количество вагонов). Прицепка/отцепка вагонов может осуществляться только если поезд не движется.
Может принимать маршрут следования (объект класса Route).
При назначении маршрута поезду, поезд автоматически помещается на первую станцию в маршруте.
Может перемещаться между станциями, указанными в маршруте. Перемещение возможно вперед и назад, но только на 1 станцию за раз.
Возвращать предыдущую станцию, текущую, следующую, на основе маршрута
=end

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
if $0 == __FILE__
  station = Station.new('Минск-Центральный')
  station2 = Station.new('Молодечно')

  train = Train.new

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
  p station
  p train
  p route
end
