require_relative 'stamp.rb'

# должен ли вагон знать о поезде? - нет, вагон это пассив, прицепили, отцепили
# должен ли вагон знать, прицеплен он или нет? Никто не будет цеплять прицепленный вагон
# если вагон в поезде - он прицеплен, если в массиве свободных вагонов он отцеплен.
# где вагон? Да хрен его знает, спросите у того поезда. А может появится ещё кто-то,
# кто будет это знать.
# потенциально может понадобитьмя каждому вагону иметь конечную цель назначения,
# а может и несколько целей, но это уже другая задача
class Wagon
  include Stamp

  # Is this wagon hookable to the train?
  def hookable?(type)
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

  def type_name
    raise 'переопределить в потомках, возвращает строку типа вагона, для информации'
  end

  def to_s
    "#{type_name} ##{id}"
  end

  protected # метод закрытый, но переопределяется в потомках

  def types
    raise 'переопределить в потомках, возвращает массив типов поездов к которым можно подключить данный тип вагона'
  end
end
