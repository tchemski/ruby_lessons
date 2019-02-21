require_relative 'train.rb'

# Товарный поезд
class CargoTrain < Train
  MAX_SPEED = 100

  def self.type_name
    'товарный'
  end

  validate :speed, :limits, [0, MAX_SPEED]
end
