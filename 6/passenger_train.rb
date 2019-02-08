require_relative 'train.rb'
class PassengerTrain < Train
  MAX_SPEED = 200
  def self.type_name
    'пассажирский'
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
