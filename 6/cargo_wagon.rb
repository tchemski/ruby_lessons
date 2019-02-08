require_relative 'wagon.rb'
class CargoWagon < Wagon
  def self.type_name
    'товарный'
  end

  protected

  def types
    [CargoTrain]
  end
end
