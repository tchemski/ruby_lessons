require_relative 'wagon.rb'

# грузовых вагонов
class CargoWagon < Wagon
  VOLUME_UNIT_NAME = 'м³'.freeze
  DEFAULT_MAX_VOLUME = 75.0

  attr_reader :free_vol, # возвращает оставшийся (доступный) объем
              :max_vol   # атрибут общего объема (задается при создании вагона)

  def self.types
    [CargoTrain]
  end

  def self.type_name
    'товарный'
  end

  def initialize(max_vol = '')
    super()
    max_vol = DEFAULT_MAX_VOLUME if max_vol.to_s.empty?
    @free_vol = @max_vol = max_vol.to_f
    validate_v! @max_vol
    @max_vol.freeze
  end

  # метод, которые "занимает объем" в вагоне (объем в качестве параметра)
  def load(vol)
    vol = vol.to_f
    raise 'нет свободного объёма' if vol > free_vol

    validate_v! vol
    @free_vol -= vol
  end

  def unload(vol = '')
    vol = vol.to_f
    raise 'вагон пуст' if empty?

    validate_v! vol
    if vol >= filled_vol # опустошаем всё
      unloading_vol = filled_vol
      @free_vol = @max_vol
      return unloading_vol # сколько было
    else
      @free_vol += vol
    end
  end

  def empty?
    free_vol == max_vol
  end

  # метод, который возвращает занятый объем
  def filled_vol
    max_vol - free_vol
  end

  def percent
    filled_vol / max_vol * 100
  end

  def to_s
    "[##{id}, #{self.class.type_name}-#{max_vol},"\
    " #{free_vol} ,#{percent.round(1)}%]"
  end

  protected

  def validate_v!(vol)
    raise 'объем должен быть положительным числом' if vol < 0
  end
end
