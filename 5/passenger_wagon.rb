require_relative 'wagon.rb'
class PassengerWagon < Wagon
  def type_name
    'пассажирский'
  end

  protected

  def types
    [PassengerTrain]
  end
end
