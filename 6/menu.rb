class Menu
  MAIN_MENU = 'Главное меню'.freeze
  EXIT = 'Выход'.freeze
  SELECT_ITEM = 'Введите действие'.freeze
  NO_ITEM = 'Такого пункта нет'.freeze
  NO_CHOICE = 'Нет выбора'.freeze
  # ONE_CHOICE = 'Единственный возможный выбор сделан'
  DOUBLE_LINE = '=' * 40
  LINE = '-' * 40
  SELECT_NUMBER = 'Выбор номера'.freeze

  def initialize(items = {}, name_menu = MAIN_MENU)
    @name_menu = name_menu
    @items = {}
    counter = 0
    items.each { |item_name, action| @items[counter += 1] = [item_name, action] }
    @items.merge!(0 => [EXIT, nil])
  end

  # Запрашивает у пользователя и возвращает номер элемента массива либо nil
  # Если массив пустой возвращает nil и сообщает NO_CHOICE
  def self.get_array_id(array, name_menu = SELECT_NUMBER)
    counter = 0
    Menu.head_puts name_menu
    array.each { |e| puts "#{counter += 1}. #{e}" }
    if counter.zero?
      puts LINE
      puts NO_CHOICE
      return nil
      # Если массив с одним элементом возвращает 0 и сообщает ONE_CHOICE
      # В некоторых случаях приводит к зацикливанию меню
      # elsif counter == 1
      #   puts LINE
      #   puts ONE_CHOICE
      #   return 0
    end
    puts "0. #{EXIT}"
    puts LINE
    loop do
      print "#{SELECT_ITEM}:"
      number = gets.to_i
      if (1..array.size).cover?(number)
        return number - 1
      elsif number == 0
        return nil
      else
        puts "#{NO_ITEM}."
      end
    end
  end

  def self.head_puts(head)
    puts DOUBLE_LINE
    puts head
    puts LINE
  end

  # возвращает proc объект для отрисовки меню и запроса у пользователя
  def get_proc
    proc do
      loop do
        Menu.head_puts @name_menu
        @items.each { |item, value| puts "#{item}. #{value[0]}" }
        puts LINE
        print "#{SELECT_ITEM}:"
        item = gets.to_i
        break if item == 0
        next unless @items[item]

        @items[item][1].call
      end
    end
  end
end
