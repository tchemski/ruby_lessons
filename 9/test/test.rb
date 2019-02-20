require_relative 'route.rb'
require_relative 'validations.rb'

class Test
  attr_accessor :station
  validate :station, :type, Station
end
