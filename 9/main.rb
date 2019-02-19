#!/usr/bin/ruby -w

require_relative 'route.rb'
require_relative 'menu.rb'

stations = Station.all # массив станций AutoArray
routes = Route.all
trains = Train.all

######### Подменю станций ########
add_station = proc {
  begin
    puts Menu::LINE
    print 'Введите название станции:'
    station = Station.new(gets.chomp)
    puts "станция \"#{station}\" добавлена"
  rescue RuntimeError
    puts Station::NAME_ERROR_MSG.to_s
    retry
  end
}

delete_station = proc {
  (id = Menu.array_id(stations, 'Выбор станции для удаления')) || next

  stations.delete_at(id)
}

info_station = proc {
  (id = Menu.array_id(stations, 'Выбор станции')) || next

  Menu.head_puts "станция:#{stations[id].name}"
  puts 'поезда:'
  stations[id].trains.each { |t| puts t }
}

stations_menu = Menu.new(
  { 'Добавить станцию' => add_station,
    'Удалить станцию' => delete_station,
    'Информация по станции' => info_station },
  'Меню станций'
).get_proc

######## Подменю маршрутов #########
add_route = proc {
  selected_stations = []
  loop do
    id = Menu.array_id(
      stations,
      "Добавление станции к маршруту\n#{selected_stations.join('->')}"
    ) || break

    puts Menu::LINE
    selected_stations << stations[id]
  end
  begin
    route = Route.new(*selected_stations)
    puts "Создан маршрут #{route}"
  rescue RuntimeError, ArgumentError
    puts 'Маршрут не создан. Станций не должно быть меньше двух, станции не '\
         'должны повторяться.'
  end
}

delete_route = proc {
  id = Menu.array_id(routes, 'Выбор маршрута для удаления') || next
  routes.delete_at(id)
}

# подменю редактирования маршрута
class Route
  def add_station_menu_proc
    proc do
      station_id =
        Menu.array_id(stations, 'Какую станцию добавить в маршрут')

      current_id =
        Menu.array_id(stations[0..-2], 'После какой станции вставить')

      begin
        insert_stations_after(stations[current_id], stations[station_id])
        puts "Станция '#{stations[station_id]}}' добавлена после "\
             "#{stations[current_id]}"
      rescue FrozenError
        puts 'нельзя редактировать маршрут добавленный к поезду'
      rescue RuntimeError
        puts 'не удалось добавить станцию'
      end
    end
  end

  def delete_station_menu_proc
    proc do
      begin
        station_id =
          Menu.array_id(tations, 'Выбор станции для удаления из маршрута')
        delete_stations(stations[station_id])
      rescue RuntimeError, TypeError
        puts 'невозможно удалить эту станцию'
      end
    end
  end
end

edit_route = proc do
  id = Menu.array_id(routes, 'Выбор маршрута для редактирования') || next
  route = routes[id]
  Menu.new(
    { 'Добавление станции' => route.add_station_menu_proc,
      'Удаление станции' => route.delete_station_menu_proc },
    "Редактирование маршрута #{routes[id]}"
  ).get_proc.call
end

show_routes = proc {
  Menu.head_puts 'Доступные маршруты'
  routes.each { |r| puts r }
}

routes_menu = Menu.new(
  { 'Создать маршрут' => add_route,
    'Удалить маршрут' => delete_route,
    'Редактировать маршрут' => edit_route,
    'Список маршрутов' => show_routes },
  'Меню маршрутов'
).get_proc

########## Подменю поездов ##########
add_train = proc {
  type_names = Train.descendants.map(&:type_name)
  loop do
    id = Menu.array_id(type_names, 'Тип поезда') || break

    begin
      puts Menu::LINE
      print 'Введите номер поезда, либо ENTER для генерации случайного номера:'
      train = Train.descendants[id].new(gets.chomp)
      puts "добавлен поезд #{train}"
    rescue RuntimeError
      # TODO: по хорошему не хватает подклассов ошибок чтоб разделять эти
      #       события
      if Train.find(id)
        puts 'Поезд с таким номером существует'
      else
        puts 'Неправильный формат номера поезда'
      end
      retry
    end
  end
}

delete_train = proc {
  loop do
    id = Menu.array_id(trains, 'Какой поезд удалить') || next

    train = trains.delete_at(id)
    puts "удалён поезд #{train}"
  end
}

info_trains = proc {
  Menu.head_puts 'Список поездов'
  trains.each { |t| puts "#{t} #{t.station}" }
}

route_train = proc {
  train_id = Menu.array_id(
    trains,
    'Выберите поезд которому нужно задать маршрут'
  ) || next

  route_id = Menu.array_id(
    routes,
    "Выберите маршрут для поезда #{trains[train_id]}"
  ) || next

  trains[train_id].route = routes[route_id]
}

class Train
  def speed_menu_proc
    proc {
      print 'введите скорость:'
      begin
        self.speed = gets.to_i
        puts "поезд #{self}"
      rescue RuntimeError
        puts 'не удаётся установить такую скорость'
      end
    }
  end

  def stop_menu_proc
    proc {
      stop
      puts "поезд #{self}"
    }
  end

  def forward_menu_proc
    proc do
      begin
        move_forward
        puts "поезд #{self} #{station}"
      rescue RuntimeError
        puts 'не удаётся двигаться по такому маршруту'
      rescue NoMethodError
        puts 'вначале задайте маршрут поезду'
      end
    end
  end

  def backward_menu_proc
    proc do
      begin
        move_backward
        puts "поезд #{self} #{station}"
      rescue RuntimeError
        puts 'не удаётся двигаться по такому маршруту'
      rescue NoMethodError
        puts 'вначале задайте маршрут поезду'
      end
    end
  end
end

drive_train = proc {
  id = Menu.array_id(trains, 'Выберите поезд которым управлять') || next

  train = trains[id]

  unless train.route
    puts 'нельзя управлять поездом у которого нет маршрута'
    next
  end

  # меню управления поездом
  Menu.new(
    { 'Установить скорость' => train.speed_menu_proc,
      'Остановиться' => train.stop_menu_proc,
      'Переместиться вперёд' => train.forward_menu_proc,
      'Переместиться назад' => train.backward_menu_proc },
    "Управление #{train.class.type_name} поездом ##{train.id}"
  ).get_proc.call
}

trains_menu = Menu.new(
  { 'Добавить поезд' => add_train,
    'Удалить поезд' => delete_train,
    'Информация о поездах' => info_trains,
    'Назначить маршрут' => route_train,
    'Управлять поездом' => drive_train },
  'Меню поездов'
).get_proc

########## Подменю вагонов ##########
class Wagon
  # фабрика вагонов
  def self.concrete_menu(train)
    # уточняем тип вагона
    wagon_types = Wagon.descendants.select { |w| w.hookable?(train.class) }
    type_names = wagon_types.map(&:type_name)
    id = Menu.array_id(type_names, 'Какой вагон прицепить') || (return nil)
    begin
      # немножко полиморфизма на уровне классов
      wagon_types[id].concrete_menu
    rescue RuntimeError
      raise # ещё наверх
    end
  end
end

class PassengerWagon
  def self.concrete_menu
    # уточняем параметры вагона
    Menu.head_puts 'Введите максимальное количество мест в вагоне'
    print "(по умолчанию #{DEFAULT_MAX_SEATS_NUMBER}):"
    begin
      new(gets.chomp)
    rescue RuntimeError
      puts 'Количество мест не может быть таким'
      raise
    end
  end
end

class CargoWagon
  def self.concrete_menu
    Menu.head_puts 'Введите максимальное объём груза в вагоне, '
    print "(по умолчанию #{DEFAULT_MAX_VOLUME})"\
          ", #{VOLUME_UNIT_NAME}:"
    begin
      new(gets.chomp)
    rescue RuntimeError
      puts 'Объём не может быть таким'
      raise # выбрасываем ошибку наверх
    end
  end
end

hook_wagons = proc {
  id = Menu.array_id(trains, 'Выберите поезд') || next
  train = trains[id]
  loop do
    begin
      wagon = Wagon.concrete_menu(train) || break
      train.hook_wagon wagon
      puts "добавлен вагон #{wagon} в поезд #{train}"
      wagon = nil # сбрасываем вагон, чтоб не добавить его ещё раз
    rescue RuntimeError
      puts "невозможно прицепить вагон #{wagon} к поезду #{train}"
    rescue NoMethodError # undefined method `hookable?'
      puts 'Вагон не создан и не прицеплен'
    end
  end
}

unhook_wagons = proc {
  loop do
    id = Menu.array_id(trains,
                       'Выберите поезд у которого отцепить вагон') || break

    train = trains[id]
    begin
      wagon = train.unhook_wagon
      puts "вагон #{wagon} отцеплен от поезда #{train}"
    rescue RuntimeError
      puts "не получается отцепить вагон от поезда #{train}"
    end
  end
}

class PassengerWagon
  def take_seats_menu_proc
    proc do
      begin
        take_seat
        puts "Пассажир добавлен в #{self}"
      rescue RuntimeError
        puts 'Свободных мест нет'
      end
    end
  end

  def release_seat_menu_proc
    proc do
      begin
        release_seat
        puts "Пассажир выгружен из #{self}"
      rescue RuntimeError
        puts 'Все места свободны'
      end
    end
  end

  def menu_proc
    Menu.new(
      { 'Добавить пассажира' => take_seats_menu_proc,
        'Выгнать пассажира' => release_seat_menu_proc },
      'Меню пассажирского вагона'
    ).get_proc
  end
end

class CargoWagon
  def load_menu_proc
    proc do
      Menu.head_puts "Введите объём загрузки вагона #{self}"
      print ", #{CargoWagon::VOLUME_UNIT_NAME}:"
      begin
        load gets.chomp
        puts "Груз загружен в #{self}"
      rescue RuntimeError
        puts "Груз не вмещается в #{self}"
      end
    end
  end

  def unload_menu_proc
    proc do
      Menu.head_puts "Введите объём выгрузки вагона #{self}"
      print "(ENTER выгрузить весь), #{CargoWagon::VOLUME_UNIT_NAME}:"
      begin
        unload gets.chomp
        puts "Груз выгружен из #{self}"
      rescue RuntimeError
        puts "Вагон #{self} уже пуст"
      end
    end
  end

  def menu_proc
    Menu.new(
      { 'Загрузить вагон' => load_menu_proc,
        'Разгрузить вагон' => unload_menu_proc },
      'Меню грузового вагона'
    ).get_proc
  end
end

wagon_contents = proc do
  trains_with_wagons = trains.select { |t| t.wagons_number > 0 }
  loop do
    id = Menu.array_id(trains_with_wagons, 'Выберите поезд') || break
    train = trains_with_wagons[id]

    loop do
      id = Menu.array_id(train.wagons, 'Выберите вагон') || break
      wagon = train.wagons[id]
      wagon.menu_proc.call
    end
  end
end

wagons_menu = Menu.new(
  { 'Прицепить вагоны' => hook_wagons,
    'Отцепить вагоны' => unhook_wagons,
    'Содержимое вагонов' => wagon_contents },
  'Меню вагонов'
).get_proc

########## Главное меню ###########
Menu.new(
  'Станции' => stations_menu,
  'Маршруты' => routes_menu,
  'Поезда' => trains_menu,
  'Вагоны' => wagons_menu
).get_proc.call
