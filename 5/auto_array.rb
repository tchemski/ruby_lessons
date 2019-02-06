module AutoArray
  def self.included(base)
    base.send :include, InstanceMethods
    base.send :extend, ClassMethods
    base.module_exec { self.all = [] }
  end

  module InstanceMethods
    private

    def auto_array
      self.class.all << self
    end
  end

  module ClassMethods
    #В классе создать метод класса all который возвращает все станции (объекты), созданные на данный момент
    def all
      superclass.include?(AutoArray) ? superclass.all : @all
    end

    def all=(all)
      @all = all
    end
  end
end
