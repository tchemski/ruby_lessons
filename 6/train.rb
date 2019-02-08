require_relative 'auto_array.rb'
require_relative 'stamp.rb'
require_relative 'instance_counter.rb'
require_relative 'validation.rb'
require 'securerandom'

class Train
  include AutoArray
  include Stamp
  include InstanceCounter
  # include Validation нет смысла подключать этот модуль и собирать исключения в одном месте
  # класс написан так что если он создан и работает - он валидный, все исключения обрабатываются
  # в main отдельно, не вижу смысла их сливать в один большой метод

  ID_ERROR_MSG =
    'Формат номера поезда: три латинские буквы или цифры в любом порядке, '\
    'необязательный дефис (может быть, а может нет) и еще 2 буквы или цифры'\
    ' после дефиса'.freeze
  ID_REGEXP = /^\w{3}-?\w{2}$/.freeze

  # Может возвращать текущую скорость, станцию, маршрут, массив вагонов
  attr_reader :station,
              :route,
              :speed,
              :wagons,
              :id # Имеет номер (произвольная строка)

  def initialize(id_str = '')
    self.class.type_name # не даёт создать объект Train, только потомки
    @wagons = []
    @speed = 0
    @route = nil
    self.id = id_str
    auto_array
    register_instance
  end

  def self.type_name
    raise 'переопределить метод в потомках, возвращает строку типа поезда'
  end

  def self.find(id_str)
    Train.all.detect { |t| t.id == id_str }
  end

  @@descendants = []

  def self.inherited(subclass)
    @@descendants << subclass
  end

  def self.descendants
    @@descendants
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
    # next_station ? @station = next_station : raise( "конечная, поезд дальше не идёт" )
    if next_station
      @station.send_train self # отправили
      next_station.take_train self # приняли
      @station = next_station # записали
    else
      raise('конечная, поезд дальше не идёт')
    end
  end

  # Может перемещаться между станциями, указанными в маршруте.
  # Перемещение возможно вперед и назад, но только на 1 станцию за раз.
  # (непонятно как этот метод согласуется со скоростью, мгновенные перемещения?)
  def move_backward
    if prev_station
      @station.send_train self # отправили
      prev_station.take_train self
      @station = prev_station
    else
      raise('конечная, поезд дальше не идёт')
    end
  end

  # Может набирать скорость
  def speed=(speed)
    raise "скорость не может быть меньше нуля speed = #{speed}" if speed < 0

    # TODO: по идее надо ещё максимальную скорость проверить, зависит от типа поезда
    #      и маршрута, но в условии задачи этого нет
    @speed = speed
  end

  # Может тормозить (сбрасывать скорость до нуля)
  def stop
    self.speed = 0
  end

  # При назначении маршрута поезду, поезд автоматически помещается на первую станцию в маршруте.
  # (сомнительная операция, поезд находится на некой станции, ему дали маршрут - оп,
  #  поезд на другой станции, скорость света превышена)
  # Может принимать маршрут следования (объект класса Route).
  def route=(route)
    @station.send_train self if @route
    @route = route
    @station = route.begin_station
    @station.take_train self
  end

  # Может прицеплять (метод просто увеличивает или уменьшает количество вагонов).
  def hook_wagon(wagon)
    # Прицепка/отцепка вагонов может осуществляться только если поезд не движется.
    raise 'нельзя цеплять вагон к движещемуся поезду' if speed > 0

    # проверка на соотвествие типа вагона
    unless wagon.hookable? self.class
      raise "нельзя цеплять #{wagon.class.type_name} к поезду типа '#{self.class.type_name}'"
    end

    # TODO: проверка на максимальную длинну
    wagons << wagon
  end

  # отцеплять вагоны (по одному вагону за операцию)
  def unhook_wagon
    # Прицепка/отцепка вагонов может осуществляться только если поезд не движется.
    raise 'нельзя отцеплять вагон от движущегося поезда' if speed > 0
    raise 'нельзя отцепить вагон которого не существует' if wagons_number < 1

    wagons.pop
  end

  # Может возвращать количество вагонов
  def wagons_number
    @wagons.size
  end

  def to_s
    "#{self.class.type_name} ##{id} lenght:#{wagons_number} speed:#{speed}"
  end

  private

  def id=(id_str)
    id_str = id_str.empty? ? generate_id_str : id_str.to_s.upcase
    raise 'Поезд с таким номером существует' if Train.find(id_str)
    raise ID_ERROR_MSG if id_str !~ ID_REGEXP

    @id = id_str
  end

  def generate_id_str
    loop do
      id_str = "#{SecureRandom.alphanumeric(3)}-#{SecureRandom.alphanumeric(2)}".upcase
      return id_str unless self.class.find(id_str)
    end
  end
end
