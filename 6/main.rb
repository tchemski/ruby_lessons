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
  if id = Menu.get_array_id(stations, 'Выбор станции для удаления')
    stations.delete_at(id)
  end
}

info_station = proc {
  if id = Menu.get_array_id(stations, 'Выбор станции')
    Menu.head_puts "станция:#{stations[id].name}"
    puts 'поезда:'
    stations[id].each_train { |t| puts t }
  end
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
  while id = Menu.get_array_id(stations,
                               "Добавление станции к маршруту\n" \
                               "#{selected_stations.join('->')}")
    puts Menu::LINE
    selected_stations << stations[id]
  end
  begin
    route = Route.new(*selected_stations)
    puts "Создан маршрут #{route}"
  rescue RuntimeError, ArgumentError
    puts 'Маршрут не создан. Станций не должно быть меньше двух, станции не должны повторяться.'
  end
}

delete_route = proc {
  if id = Menu.get_array_id(routes, 'Выбор маршрута для удаления')
    routes.delete_at(id)
  end
}

edit_route = proc {
  if id = Menu.get_array_id(routes, 'Выбор маршрута для редактирования')
    route = routes[id]
    # подменю редактирования маршрута
    add_station_route = proc {
      station_id = Menu.get_array_id(stations,
                                     'Какую станцию добавить в маршрут')
      current_id = Menu.get_array_id(route.stations[0..-2],
                                     'После какой станции вставить')
      begin
        route.insert_stations_after(route.stations[current_id], stations[station_id])
        puts "Станция '#{stations[station_id]}}' добавлена после #{route.stations[current_id]}"
      rescue FrozenError
        puts 'нельзя редактировать маршрут добавленный к поезду'
      rescue RuntimeError
        puts 'не удалось добавить станцию'
      end
    }

    delete_station_route = proc {
      begin
        routes[id].delete_stations(
          routes[id].stations[
            Menu.get_array_id(routes[id].stations,
                              'Выбор станции для удаления из маршрута')
          ]
        )
      rescue RuntimeError, TypeError
        puts 'невозможно удалить эту станцию'
      end
    }

    Menu.new(
      { 'Добавление станции' => add_station_route,
        'Удаление станции' => delete_station_route },
      "Редактирование маршрута #{routes[id]}"
    ).get_proc.call
  end
}

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
  while id = Menu.get_array_id(type_names,
                               'Тип поезда')
    begin
      puts Menu::LINE
      print 'Введите номер поезда, либо ENTER для генерации случайного номера:'
      train = Train.descendants[id].new(gets.chomp)
      puts "добавлен поезд #{train}"
    rescue RuntimeError
      if Train.find(id) # TODO: по хорошему не хватает подклассов ошибок чтоб разделять эти события
        puts 'Поезд с таким номером существует'
      else
        puts 'Неправильный формат номера поезда'
      end
      retry
    end
  end
}

delete_train = proc {
  while id = Menu.get_array_id(trains,
                               'Какой поезд удалить')
    train = trains.delete_at(id)
    puts "удалён поезд #{train}"
  end
}

info_trains = proc {
  Menu.head_puts 'Список поездов'
  trains.each { |t| puts "#{t} #{t.station}" }
}

route_train = proc {
  if (train_id = Menu.get_array_id(trains,
                                   'Выберите поезд которому нужно задать маршрут')) &&
     (route_id = Menu.get_array_id(routes,
                                   "Выберите маршрут для поезда #{trains[train_id]}"))

    trains[train_id].route = routes[route_id]
  end
}

drive_train = proc {
  if id = Menu.get_array_id(trains,
                            'Выберите поезд которым управлять')
    # меню управления поездом
    train = trains[id]
    if trains[id].route
      speed_train = proc {
        print 'введите скорость:'
        begin
          train.speed = gets.to_i
          puts "поезд #{train}"
        rescue RuntimeError
          puts 'не удаётся установить такую скорость'
        end
      }
      stop_train = proc {
        train.stop
        puts "поезд #{train}"
      }
      forward_train = proc {
        begin
          train.move_forward
          puts "поезд #{train} #{train.station}"
        rescue RuntimeError
          puts 'не удаётся двигаться по такому маршруту'
        rescue NoMethodError
          puts 'вначале задайте маршрут поезду'
        end
      }
      backward_train = proc {
        begin
          train.move_backward
          puts "поезд #{train} #{train.station}"
        rescue RuntimeError
          puts 'не удаётся двигаться по такому маршруту'
        rescue NoMethodError
          puts 'вначале задайте маршрут поезду'
        end
      }
      Menu.new(
        { 'Установить скорость' => speed_train,
          'Остановиться' => stop_train,
          'Переместиться вперёд' => forward_train,
          'Переместиться назад' => backward_train },
        "Управление #{train.class.type_name} поездом ##{train.id}"
      ).get_proc.call
    else # trains[id].route
      puts 'нельзя управлять поездом у которого нет маршрута'
    end
  end
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

hook_wagons = proc {
  if id = Menu.get_array_id(trains, 'Выберите поезд')
    train = trains[id]
    wagon_types = Wagon.descendants.select { |w| w.hookable? train.class }
    type_names = wagon_types.map(&:type_name)
    while id = Menu.get_array_id(type_names, 'Какой вагон прицепить')
      wagon_type = wagon_types[id]
      #  TODO где-то просится ещё один класс типа "адаптер", либо proc-объект
      #  для адаптации меню к типу вагона, однако вводить пользователю каждый раз
      #  параметры вагона - зло, потому что конструкция вагона конкретна и не
      #  меняется. Лучше иметь что-то типа "Конструктор вагонов", поэтому пока так:
      if wagon_type == PassengerWagon
        Menu.head_puts 'Введите максимальное количество мест в вагоне'
        print "(по умолчанию #{PassengerWagon::DEFAULT_MAX_SEATS_NUMBER}):"
        begin
          wagon = wagon_type.new gets.chomp
        rescue RuntimeError
          puts 'Количество мест не может быть таким'
        end
      elsif wagon_type == CargoWagon
        Menu.head_puts 'Введите максимальное объём груза в вагоне, '
        print "(по умолчанию #{CargoWagon::DEFAULT_MAX_VOLUME})"\
              ", #{CargoWagon::VOLUME_UNIT_NAME}:"
        begin
          wagon = wagon_type.new gets.chomp
        rescue RuntimeError
          puts 'Объём не может быть таким'
        end
      else
        wagon = wagon_type.new
      end
      begin
        train.hook_wagon wagon
        puts "добавлен вагон #{wagon} в поезд #{train}"
        wagon = nil # сбрасываем вагон, чтоб не добавить его ещё раз
      rescue RuntimeError
        puts "невозможно прицепить вагон #{wagon} к поезду #{train}"
      rescue NoMethodError # undefined method `hookable?'
        puts 'Вагон не создан и не прицеплен'
      end
    end
  end
}

unhook_wagons = proc {
  while id = Menu.get_array_id(trains, 'Выберите поезд у которого отцепить вагон')
    train = trains[id]
    begin
      wagon = train.unhook_wagon
      puts "вагон #{wagon} отцеплен от поезда #{train}"
    rescue RuntimeError
      puts "не получается отцепить вагон от поезда #{train}"
    end
  end
}

wagon_contents = proc {
  trains_with_wagons = trains.select { |t| t.wagons_number > 0 }
  while id = Menu.get_array_id(trains_with_wagons, 'Выберите поезд')
    train = trains_with_wagons[id]
    while id = Menu.get_array_id(train.wagons, 'Выберите вагон')
      wagon = train.wagons[id]
      if wagon.class == PassengerWagon
        Menu.new(
          { 'Добавить пассажира' =>
              proc do
                begin
                  wagon.take_seat
                  puts "Пассажир добавлен в #{wagon}"
                rescue RuntimeError
                  puts 'Свободных мест нет'
                end
              end,
            'Выгнать пассажира' =>
              proc do
                begin
                  wagon.release_seat
                  puts "Пассажир выгружен из #{wagon}"
                rescue RuntimeError
                  puts 'Все места свободны'
                end
              end },
          'Меню пассажирского вагона'
        ).get_proc.call
      elsif wagon.class == CargoWagon
        Menu.new(
          { 'Загрузить вагон' =>
              proc do
                Menu.head_puts "Введите объём загрузки вагона #{wagon}"
                print ", #{CargoWagon::VOLUME_UNIT_NAME}:"
                begin
                  wagon.load gets.chomp
                  puts "Груз загружен в #{wagon}"
                rescue RuntimeError
                  puts "Груз не вмещается в #{wagon}"
                end
              end,
            'Разгрузить вагон' =>
              proc do
                Menu.head_puts "Введите объём выгрузки вагона #{wagon}"
                print "(ENTER выгрузить весь), #{CargoWagon::VOLUME_UNIT_NAME}:"
                begin
                  wagon.unload gets.chomp
                  puts "Груз выгружен из #{wagon}"
                rescue RuntimeError
                  puts "Вагон #{wagon} уже пуст"
                end
              end },
          'Меню грузового вагона'
        ).get_proc.call
      end
    end
  end
}

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
