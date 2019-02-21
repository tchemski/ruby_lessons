module Validation
  def self.included(base)
    base.include InstanceMethods
    base.extend ClassMethods
  end

  module ClassMethods
    # возвращает хэш валидаций для текущего класса для добавления, но
    # в блок йелдит список всех валидаций, в том числе предков, для проверок
    def validations(klass = self, &block)
      # если списка валидаций ещё нет - создаём для каждого подкласса свой
      @validations ||= Hash.new { |hash, key| hash[key] = [] }

      if block_given?
        # рекурсивно просматриваем все надклассы включающие Validation
        if klass.superclass.include?(Validation)
          validations(klass.superclass, &block)
        end

        vals = klass.instance_variable_get(:@validations)
        # список текущего класса
        vals.each_pair do |variable, validations_list|
          yield(variable, validations_list)
        end
      end

      @validations
    end

    def validate(variable, validation, param = nil)
      # проверяем
      unless variable.is_a?(Symbol)
        raise TypeError, 'Validation variable name is not a Symbol'
      end

      unless validation.is_a?(Symbol)
        raise TypeError, 'Validation type is not a Symbol'
      end

      # добавляем в список проверок
      validations[variable].push(validation, param)
    end
  end

  module InstanceMethods
    def validate!
      self.class.validations do |variable, validations_list|
        validations_list.each_slice(2) do |validation, param|
          validator = Validation::Validator.all[validation]
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

  class Validator
    DEFAULT_PARAM_PROC = proc {}
    DEFAULT_VALIDATION_PROC =
      proc {
        raise "без процедуры проверки валидатор #{validation} не имеет смысла"
      }

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

  load 'validations.rb'
end
