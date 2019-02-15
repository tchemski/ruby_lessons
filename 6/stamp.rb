# Создать модуль, который позволит указывать название компании-производителя и
# получать его.
module Stamp
  attr_writer :manufacturer

  def manufacturer
    defined?(@manufacturer) ? @manufacturer : 'noname'
  end
end
