require_relative 'train.rb'

class PassengerTrain < Train
  MAX_SPEED = 200
  def self.type_name
    'пассажирский'
  end

  validate :speed, :limits, [0, MAX_SPEED]
end
