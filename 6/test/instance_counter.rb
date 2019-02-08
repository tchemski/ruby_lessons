#!/usr/bin/ruby -w
# test # test # test # test # test # test # test # test # test # test # test

require_relative '../instance_counter.rb'

class Test
  include InstanceCounter

  def initialize
    register_instance
  end
end

class Test2 < Test;  end

10.times{Test.new}
5.times{Test2.new}
puts Test.instances
puts Test2.instances
