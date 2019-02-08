require_relative 'wagon.rb'
class PassengerWagon < Wagon
  def self.type_name
    'пассажирский'
  end

  protected

  def types
    [PassengerTrain]
  end
end
