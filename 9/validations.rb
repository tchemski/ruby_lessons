# Вынес в отдельный файл валидации которые подгружаются автоматически при
# include Validate.
#
# Добавить валидацию просто:
#
# Validation::Validator.all[:val].validation =
#   proc{|variable, instance, param|
#     #делаем проверки, бросаем исключение с сообщением если надо.
#   }
# Всё, новая валидация готова.
#
# :val - имя нового типа валидации
# variable - имя переменной
# instance - значение
# param - параметры проверки
#
# Дополнительно можно добавить проверку параметра валидации,
# вызывается при validate, но не при validate!
# Делается это так:
#
# Validation::Validator.all[:val].param_validation = proc{|param|
#   #делаем проверку param, бросаем исключение если надо
# }
#
# Все созданные валидаторы могут использоваться при validate!, либо напрямую
# validator = Validation::Validator.all[:presence]
# validator.call(:variable_name, instance, param)

all = Validation::Validator.all

############## validate :name, :presence ##############
# не пропускает nil или ''. Без параметра, param не задействован.
all[:presence].validate = proc { |variable, instance, _param|
  raise "No presence @#{variable}" if instance.to_s.empty?
}

############## validate :number, :format, /[A-Z]{0,3}/ ##############
# не пропускает nil или не соответствующее шаблону Regexp
all[:format].param_validate = proc { |param|
  raise TypeError, "validate 'format' param is not а Regexp"\
    unless param.is_a?(Regexp)
}
all[:format].validate = proc { |variable, instance, param|
  raise "@#{variable} =~ #{param.inspect} is false" unless instance =~ param
}

############## validate :station, :type, RailwayStation ##############
# пропускает только заданный тип или nil
all[:type].param_validate = proc { |param|
  unless param.is_a?(Class)
    raise TypeError, "validate 'type' param is not а Class"
  end
}
all[:type].validate = proc { |variable, instance, param|
  next if instance.nil?
  raise "Type @#{variable} is not a #{param}" unless instance.is_a?(param)
}

############## validate :speed, :limits, [0,100] ##############
# пропускает nil но не пропускает меньше или больше заданной границы
all[:limits].param_validate = proc { |param|
  unless param.is_a?(Array)\
         && (param.last >= param.first)\
         && (param.size == 2)
    raise TypeError, "validate 'limits' param is not а correct"
  end
}
all[:limits].validate = proc { |variable, instance, param|
  next if instance.nil?
  unless (instance >= param.first) && (instance <= param.last)
    raise "Limits @#{variable} is not in #{param}"
  end
}
