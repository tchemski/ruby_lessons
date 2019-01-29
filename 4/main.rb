#!/usr/bin/ruby -w

require_relative 'route.rb'
require_relative 'menu.rb'

stations = []
routes = []
trains = []

# Подменю станций
add_station = proc {
  puts Menu::LINE
  print 'Введите название станции:'
  stations << Station.new(gets.chomp)
}

delete_station = proc {
  if id = Menu.get_array_id(stations, 'Выбор станции для удаления')
    stations.delete_at(id)
  end
}

info_station = proc {
  if id = Menu.get_array_id(stations, 'Выбор станции')
    Menu.puts_head "станция:#{stations[id].name}"
    puts 'поезда:'
    stations[id].trains.each { |t| puts t }
  end
}

stations_menu = Menu.new(
  { 'Добавить станцию' => add_station,
    'Удалить станцию' => delete_station,
    'Информация по станции' => info_station },
  'Меню станций'
).get_proc

# Подменю маршрутов
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
    routes << route
    puts "Создан маршрут #{route}"
  rescue RuntimeError, ArgumentError
    puts 'Маршрут не создан'
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
        puts "Станция 'stations[station_id]}' добавлена после route.stations[current_id]"
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
      rescue RuntimeError
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
  Menu.puts_head 'Доступные маршруты'
  routes.each { |r| puts r }
}

routes_menu = Menu.new(
  { 'Создать маршрут' => add_route,
    'Удалить маршрут' => delete_route,
    'Редактировать маршрут' => edit_route,
    'Список маршрутов' => show_routes },
  'Меню маршрутов'
).get_proc

# Подменю поездов

add_train = proc {
  type_names = Train.descendants.map { |t| t.new.type_name }
  while id = Menu.get_array_id(type_names,
                               'Тип поезда')
    train = Train.descendants[id].new
    trains << train
    puts "добавлен поезд #{train}"
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
  Menu.puts_head 'Список поездов'
  trains.each { |t| puts t }
}

hook_wagons = proc {
  if id = Menu.get_array_id(trains, 'Выберите поезд')
    train = trains[id]
    type_names = Wagon.descendants.map { |t| t.new.type_name }
    while id = Menu.get_array_id(type_names, 'Какой вагон добавить')
      wagon = Wagon.descendants[id].new
      begin
        train.hook_wagon wagon
        puts "добавлен вагон #{wagon} в поезд #{train}"
      rescue RuntimeError
        puts "невозможно прицепить вагон #{wagon} к поезду #{train}"
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
      end
    }
    backward_train = proc {
      begin
        train.move_backward
        puts "поезд #{train} #{train.station}"
      rescue RuntimeError
        puts 'не удаётся двигаться по такому маршруту'
      end
    }
    Menu.new(
      { 'Установить скорость' => speed_train,
        'Остановиться' => stop_train,
        'Переместиться вперёд' => forward_train,
        'Переместиться назад' => backward_train },
      "Управление #{train.type_name} поездом ##{train.id}"
    ).get_proc.call
  end
}

trains_menu = Menu.new(
  { 'Добавить поезд' => add_train,
    'Удалить поезд' => delete_train,
    'Информация о поездах' => info_trains,
    'Прицепить вагоны' => hook_wagons,
    'Отцепить вагоны' => unhook_wagons,
    'Назначить маршрут' => route_train,
    'Управлять поездом' => drive_train },
  'Меню поездов'
).get_proc

# Главное меню
Menu.new(
  'Станции' => stations_menu,
  'Маршруты' => routes_menu,
  'Поезда' => trains_menu
).get_proc.call
