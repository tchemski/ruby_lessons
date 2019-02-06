# Создать модуль InstanceCounter, содержащий следующие методы класса и инстанс-методы, которые подключаются автоматически при вызове include в классе:
# Методы класса:
#        - instances, который возвращает кол-во экземпляров данного класса
# Инастанс-методы:
#        - register_instance, который увеличивает счетчик кол-ва экземпляров класса и который можно вызвать из конструктора. При этом данный метод не должен быть публичным.
# Подключить этот модуль в классы поезда, маршрута и станции.
# Примечание: инстансы подклассов могут считатья по отдельности, не увеличивая счетчик инстансев базового класса.

module InstanceCounter
  def self.included(base)
    base.send :include, InstanceMethods
    base.send :extend, ClassMethods
    base.module_exec { self.instances = 0 }
  end

  module InstanceMethods
    private

    def register_instance
      self.class.send :instances=, self.class.instances + 1
    end
  end

  module ClassMethods
    def instances
      superclass.include?(InstanceCounter) ? superclass.instances : @instances
    end

    private

    def instances=(i)
      superclass.include?(InstanceCounter) ? superclass.send(:instances=, i) : @instances = i
    end
  end
end
