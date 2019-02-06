# Создать модуль InstanceCounter, содержащий следующие методы класса и инстанс-методы, которые подключаются автоматически при вызове include в классе:
# Методы класса:
#        - instances, который возвращает кол-во экземпляров данного класса
# Инастанс-методы:
#        - register_instance, который увеличивает счетчик кол-ва экземпляров класса и который можно вызвать из конструктора. При этом данный метод не должен быть публичным.
# Подключить этот модуль в классы поезда, маршрута и станции.
# Примечание: инстансы подклассов могут считатья по отдельности, не увеличивая счетчик инстансев базового класса.

module InstanceCounter
  def self.included(base)
    base.include InstanceMethods
    base.extend ClassMethods
  end

  module InstanceMethods
    private

    def register_instance
      self.class.send :increase_instances
    end
  end

  module ClassMethods
    def instances
      @instances ||= 0
    end

    private

    def increase_instances
      @instances = instances + 1
    end
  end
end
