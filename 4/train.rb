class Train
  # Может возвращать текущую скорость, станцию, маршрут, массив вагонов
  attr_reader :station,
              :route,
              :speed,
              :wagons

  def initialize
    type_name # не даёт создать объект Train, только потомки
    @wagons = []
    @speed = 0
  end

  def type_name
    raise 'переопределить метод в потомках, возвращает строку типа поезда'
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
      raise "нельзя цеплять #{wagon.type_name} к поезду типа '#{type_name}'"
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

  # Имеет номер (произвольная строка)
  def id
    object_id
  end

  def to_s
    "#{type_name} ##{id} lenght:#{wagons_number} speed:#{speed}"
  end
end
