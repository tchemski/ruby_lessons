require_relative 'wagon.rb'
class CargoWagon < Wagon
  def type_name
    'товарный'
  end

  protected

  def types
    [CargoTrain]
  end
end
