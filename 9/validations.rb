module Validations
  def self.included(base)
    base.include InstanceMethods
    base.extend ClassMethods
  end

  module ClassMethods
    def validations
      defined?(@validations) ? @validations : superclass.validations
    end

    def validate(variable, validation, param = nil)
      # проверяем
      raise TypeError, 'Validation variable name is not a Symbol'\
          unless variable.is_a?(Symbol)

      raise TypeError, 'Validation type is not a Symbol'\
        unless validation.is_a?(Symbol)

      validator = Validator.all[validation] || raise('Unnown validation type')
      validator.param_validate.call(param)

      # в каждом подклассе создаём свой список проверок
      # {:name=>[:presence, nil], :number=>[:format, /[A-Z]{0,3}/], :station=>[:type, String]}
      @validations ||= Hash.new { |hash, key| hash[key] = [] }

      # добавляем в список проверок
      validations[variable].push(validation, param)
    end
  end

  module InstanceMethods
    def validate!
      self.class.validations.each_pair do |variable, validations_list|
        validations_list.each_slice(2) do |validation, param|
          validator = Validator.all[validation]
          var_name = "@#{variable}".to_sym
          instance = if instance_variable_defined?(var_name)
                       instance_variable_get(var_name)
                     end
          validator.validate.call(variable, instance, param)
        end
      end
    end

    def valid?
      validate!
      true
    rescue StandardError
      false
    end
  end
end

class Validator
  DEFAULT_PARAM_PROC = proc {}
  DEFAULT_VALIDATION_PROC =
    proc { raise 'без процедуры проверки валидатор не имеет смысла' }

  attr_reader :validation

  attr_accessor :param_validate,
                :validate

  # каждый тип валидации в отдельном экземпляре Validator.new(validation)
  @all = Hash.new do |hash, key|
    hash[key] = new(key)
  end

  class << self
    attr_reader :all
  end

  def initialize(validation)
    # запускаются при validate
    @validation = validation
    all = self.class.all
    all[@validation] = self
    @param_validate = DEFAULT_PARAM_PROC
    @validate = DEFAULT_VALIDATION_PROC
  end
end

# validate :name, :presence
Validator.all[:presence].validate = proc { |variable, instance, _param|
  raise "No presence @#{variable}" if instance.to_s.empty?
}

# validate :number, :format, /[A-Z]{0,3}/
Validator.all[:format].param_validate = proc { |param|
  raise TypeError, "validate 'format' param is not а Regexp"\
    unless param.is_a?(Regexp)
}
Validator.all[:format].validate = proc { |variable, instance, param|
  raise "@#{variable} =~ #{param.inspect} is false"\
    unless instance =~ param
}

# validate :station, :type, RailwayStation
Validator.all[:type].param_validate = proc { |param|
  raise TypeError, "validate 'type' param is not а Class"\
    unless param.is_a?(Class)
}
Validator.all[:type].validate = proc { |variable, instance, param|
  raise "Type @#{variable} is not a #{param}"\
    unless instance.is_a?(param) || param.class == NilClass
}

# validate :speed, :limits, [0,100]
Validator.all[:limits].param_validate = proc { |param|
  raise TypeError, "validate 'limits' param is not а correct"\
    unless param.last >= param.first || param.size == 2
}
Validator.all[:limits].validate = proc { |variable, instance, param|
  raise "Type @#{variable} is not a #{param}"\
    unless instance >= param.first || instance <= param.last
}
