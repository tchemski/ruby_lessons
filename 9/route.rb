require_relative 'station.rb'
require_relative 'auto_array.rb'
require_relative 'instance_counter.rb'
require_relative 'validation.rb'

class Route
  include AutoArray
  include InstanceCounter
  include Validation

  # Имеет начальную и конечную станцию, а также список промежуточных станций
  # Может выводить список всех станций по-порядку от начальной до конечной
  attr_reader :stations

  # Начальная и конечная станции указываютсся при создании маршрута
  # промежуточные могут добавляться между ними
  def initialize(begin_station, *stations)
    # начало и конец маршрута
    end_station = stations.pop\
    || raise('нельзя создать маршрут менее чем из двух станций')

    raise 'такая станция уже есть на маршруте' if begin_station == end_station

    @stations = [begin_station, end_station]

    # остальные станции вставляем между
    insert_stations_after begin_station, *stations
    auto_array
    register_instance
    validate!
  end

  # Может добавлять промежуточную станцию в список
  def insert_stations_after(current, *stations)
    if current == end_station
      raise 'нельзя добавлять станции после конечной, создайте новый маршрут'
    end

    station_index = @stations.index(current)
    stations.each do |station|
      raise 'такая станция уже есть на маршруте' if include? station

      @stations.insert(station_index += 1, station)
    end
    validate!
    stations
  end

  # Может удалять промежуточную станцию из списка
  # TODO что делать если на станции поезда?
  def delete_stations(*stations)
    stations.each do |station|
      if [begin_station, end_station].include? station
        raise 'нельзя удалять начальную и конечную станцию маршрута'
      end

      @stations.delete(station)\
      || raise('такой станции не существует на маршруте')
    end
    validate!
    stations
  end

  def begin_station
    @stations.first
  end

  def end_station
    @stations.last
  end

  def include?(station)
    @stations.include?(station)
  end

  def to_s
    stations.map(&:name).join('->')
  end

  protected

  def validate!
    unless stations.all? { |s| s.is_a? Station }
      raise 'в маршрут можно добавить только Station или потомков'
    end

    raise 'маршрут не может состоять менее чем из двух станций'\
      if stations.size < 2
  end

  private

  # нельзя редактировать маршрут назначенный поезду
  def freeze
    @stations.freeze
    super
  end
end
