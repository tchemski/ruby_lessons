require_relative 'train.rb'

# Товарный поезд
class CargoTrain < Train
  MAX_SPEED = 100

  def self.type_name
    'товарный'
  end

  protected

  def validate!
    if speed > MAX_SPEED
      raise "Скорость поезда типа #{self.class.type_name} не должна привышать "\
            "#{MAX_SPEED}"
    end
    super
  end
end
