#!/usr/bin/ruby -w

require_relative '../station.rb'

if $0 == __FILE__
  Station.new 'Зелёное'
  stations = Station.all
  puts stations.class
  stations << Station.new('Лебяжий') # warning

  puts stations

  require_relative '../passenger_train.rb'
  require_relative '../train.rb'

  PassengerTrain.new

  stations[0].take_train PassengerTrain.new
  stations.delete_at(0)
  puts Station::all
end
