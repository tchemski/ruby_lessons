require_relative 'auto_array.rb'
require_relative 'instance_counter.rb'
require_relative 'validation.rb'

class Station
  include AutoArray
  include InstanceCounter
  include Validation

  NAME_ERROR_MSG =
    'Название станции может состоять из кириллицы белорусского либо русского'\
    ' алфавита, цифр, "-", " ", "\'", должно начинаться с заглавной буквы,'\
    ' быть не короче 2-х и не длиннее 30 символов.'.freeze

  NAME_REGEXP = /^[0-9А-ЯЁIЎ]{1}[0-9а-яёiў'А-ЯЁIЎ -]{1,29}$/.freeze

  # Имеет название
  attr_reader :name

  # название указывается при ее создании
  def initialize(name)
    @name = name
    validate!
    @trains = []
    auto_array
    register_instance
  end

  # Может принимать поезда (по одному за раз)
  def take_train(train)
    raise 'этот поезд уже на станции' if include? train

    @trains << train
    validate!
  end

  # Может отправлять поезда (по одному за раз, при этом,
  # поезд удаляется из списка поездов, находящихся на станции).
  def send_train(train)
    @trains.delete(train) || raise('такого поезда на этой станции нет')
    validate!
  end

  def include?(train)
    @trains.include? train
  end

  # Может возвращать список поездов на станции по типу
  # Может возвращать список всех поездов на станции
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

  protected

  def validate!
    raise NAME_ERROR_MSG if name !~ NAME_REGEXP
  end
end
