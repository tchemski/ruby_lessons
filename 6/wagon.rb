require_relative 'stamp.rb'
require_relative 'descendants.rb'

# вагон
class Wagon
  extend Descendants
  include Stamp

  # Is this wagon hookable to the train?
  def self.hookable?(type)
    types.include? type
  end

  def self.types
    raise 'переопределить в потомках, возвращает массив типов поездов к'\
          ' которым можно подключить данный тип вагона'
  end

  # Пусть будет номер у каждого вагона, для порядка
  def id
    object_id
  end

  def self.type_name
    raise 'переопределить в потомках, возвращает название типа вагона'
  end

  def to_s
    "#{self.class.type_name} ##{id}"
  end
end
