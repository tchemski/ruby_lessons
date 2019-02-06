#!/usr/bin/ruby -w

require_relative '../auto_array.rb'

# test # test # test # test # test # test # test # test # test # test # test
if $0 == __FILE__
  class Test
    include AutoArray

    def initialize
      auto_array
    end
  end

  class Test2
    include AutoArray

    def initialize
      auto_array
    end
  end

  class TestTest < Test; end
  class TestTestTest < TestTest
    def initialize
      test
      super
    end

    def test
      self.class.all
    end
  end


  TestTest.new
  TestTestTest.new

  p Test.all.object_id != Test2.all.object_id
  p Test.all.class
  p Test2.all.class

  Test.new
  Test2.new

  p Test.all
  p Test2.all

  Test.all << Test.new # warning

  p Test.all
  p TestTest.all
end
