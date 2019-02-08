require_relative 'train.rb'

# Товарный поезд
class CargoTrain < Train
  def self.type_name
    'товарный'
  end
end
