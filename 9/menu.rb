class Menu
  MAIN_MENU = 'Главное меню'.freeze
  EXIT = 'Выход'.freeze
  SELECT_ITEM = 'Выберите пункт'.freeze
  NO_ITEM = 'Такого пункта нет'.freeze
  NO_CHOICE = 'Нет выбора'.freeze
  DOUBLE_LINE = '=' * 40
  LINE = '-' * 40

  # Запрашивает у пользователя и возвращает номер элемента массива либо nil
  # Если массив пустой возвращает nil и сообщает NO_CHOICE
  class << self
    def numeric_list_puts(array)
      # вывод пронумерованного списка
      counter = 0
      array.each do |e|
        counter += 1
        puts "#{counter}. #{e}"
      end
      counter
    end

    def user_gets
      print "#{SELECT_ITEM}:"
      gets.to_i
    end

    def array_id(array, name_menu = SELECT_NUMBER)
      # заголовок
      Menu.head_puts name_menu

      if Menu.numeric_list_puts(array).zero?
        puts LINE, NO_CHOICE
        return nil
      end
      puts "0. #{EXIT}", LINE

      # запрос ввода у пользователя, если такого пункта нет, запрашивает ещё.
      # ENTER либо 0 прерывает запрос
      loop do
        number = Menu.user_gets
        return number - 1 if (1..array.size).cover?(number)
        return nil if number.zero?

        puts "#{NO_ITEM}."
      end
    end

    # Печать заголовка меню
    def head_puts(head)
      puts DOUBLE_LINE, head, LINE
    end
  end

  def initialize(items = {}, name_menu = MAIN_MENU)
    @name_menu = name_menu
    @items = {}
    counter = 0

    items.each do |item_name, action|
      counter += 1
      @items[counter] = [item_name, action]
    end
    @items.merge!(0 => [EXIT, nil])
  end

  # возвращает proc объект для отрисовки меню и запроса у пользователя
  def get_proc
    proc do
      loop do
        Menu.head_puts @name_menu
        @items.each { |item, value| puts "#{item}. #{value[0]}" }
        puts LINE
        item = Menu.user_gets
        break if item.zero?
        next unless @items[item]

        @items[item][1].call
      end
    end
  end
end
