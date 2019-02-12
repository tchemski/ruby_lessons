require_relative 'stamp.rb'

# вагон
class Wagon
  include Stamp

  # Is this wagon hookable to the train?
  def self.hookable?(type)
    types.include? type
  end

  @@descendants = []

  def self.inherited(subclass)
    @@descendants << subclass
  end

  def self.descendants
    @@descendants
  end

  # Пусть будет номер у каждого вагона, для порядка
  def id
    object_id
  end

  def self.type_name
    raise 'переопределить в потомках, возвращает строку типа вагона, для информации'
  end

  def to_s
    "#{self.class.type_name} ##{id}"
  end

  protected # метод закрытый, но переопределяется в потомках

  def self.types
    raise 'переопределить в потомках, возвращает массив типов поездов к которым '\
          'можно подключить данный тип вагона'
  end
end
