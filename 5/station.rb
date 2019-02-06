require_relative 'auto_array.rb'
require_relative 'instance_encounter.rb'

class Station
  include AutoArray
  include InstanceCounter
  # Имеет название
  attr_reader :name

  # название указывается при ее создании
  def initialize(name)
    @name = name
    @trains = []
    auto_array
    register_instance
  end

  # Может принимать поезда (по одному за раз)
  def take_train(train)
    raise 'этот поезд уже на станции' if include? train

    @trains << train
  end

  # Может отправлять поезда
  # (по одному за раз, при этом, поезд удаляется из списка поездов, находящихся на станции).
  def send_train(train)
    @trains.delete(train) || raise('такого поезда на этой станции нет')
  end

  def include?(train)
    @trains.include? train
  end

  # Может возвращать список поездов на станции по типу
  # Может возвращать список всех поездов на станции, находящиеся в текущий момент
  def trains(type = nil)
    if !type
      @trains
    else
      @trains.select { |train| train.class == type }
    end
  end

  # кол-во грузовых, пассажирских
  def trains_number(type = nil)
    if !type
      @trains.size
    else
      @trains.count { |train| train.class == type }
    end
  end

  def to_s
    name
  end
end
