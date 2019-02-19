require_relative 'wagon.rb'

# Для пассажирских вагонов
class PassengerWagon < Wagon
  DEFAULT_MAX_SEATS_NUMBER = 40

  attr_reader :free_seats_number, # кол-во свободных мест в вагоне
              :max_seats_number # общее кол-во мест

  def self.type_name
    'пассажирский'
  end

  def self.types
    [PassengerTrain]
  end

  def initialize(max_seats_number = '')
    super()

    max_seats_number = DEFAULT_MAX_SEATS_NUMBER if max_seats_number.to_s.empty?
    @free_seats_number = @max_seats_number = max_seats_number.to_i
    if (!@max_seats_number.is_a? Integer) || (@max_seats_number < 0)
      raise 'Число мест должно быть целым, положительным'
    end

    @max_seats_number.freeze
  end

  # метод, который "занимает места" в вагоне (по одному за раз)
  def take_seat
    raise 'свободных мест нет' unless any_seats_free?

    @free_seats_number -= 1
  end

  # метод, который "освобождает места" в вагоне (по одному за раз)
  def release_seat
    raise 'все места свободны' if all_seats_empty?

    @free_seats_number += 1
  end

  # есть свободные места?
  def any_seats_free?
    free_seats_number > 0
  end

  # все места свободны?
  def all_seats_empty?
    free_seats_number == max_seats_number
  end

  # метод, который возвращает кол-во занятых мест в вагоне
  def filled_seats
    max_seats_number - free_seats_number
  end

  def percent
    filled_seats.to_f / max_seats_number * 100
  end

  def to_s
    "[##{id}, #{self.class.type_name}-#{max_seats_number},"\
    " #{free_seats_number} ,#{percent.round(1)}%]"
  end
end
