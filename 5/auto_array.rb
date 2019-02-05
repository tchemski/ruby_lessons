#!/usr/bin/ruby -w

module AutoArray
  def self.included(base)
    base.send :include, InstanceMethods
    base.send :extend, ClassMethods
    base.module_exec { self.all = AutoArray::InstanceMethods::Array.new }
  end

  module InstanceMethods
    class Array < Array
      def <<(e)
        if include? e
          warn "warning: #{self.class} обновляется автоматически при создании"\
               " объекта класса-хозяина\n #{caller.join "\n"}"
        else
          super
        end
      end
    end

    private

    def auto_array
      self.class.all << self
    end
  end

  module ClassMethods
    def all
      superclass.include?(AutoArray) ? superclass.all : @all
    end

    def all=(all)
      @all = all
    end

    def instances
      all.size
    end
  end
end

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

  p Test.new.class.superclass.is_a? AutoArray
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
