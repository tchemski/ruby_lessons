# Создать модуль InstanceCounter
# Подключить этот модуль в классы поезда, маршрута и станции.
# Примечание: инстансы подклассов могут считатья по отдельности, не увеличивая
# счетчик инстансев базового класса.
module InstanceCounter
  def self.included(base)
    base.include InstanceMethods
    base.extend ClassMethods
  end

  # Инастанс-методы:
  module InstanceMethods
    private

    # увеличивает счетчик кол-ва экземпляров класса и который можно вызвать из
    # конструктора. При этом данный метод не должен быть публичным.
    def register_instance
      self.class.send :increase_instances
    end
  end

  # Методы класса:
  module ClassMethods
    # возвращает кол-во экземпляров данного класса
    def instances
      @instances ||= 0
    end

    private

    def increase_instances
      @instances = instances + 1
    end
  end
end
