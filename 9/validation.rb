# type_name => presence
# test => lambda()
# validate => lambda{presence}
# name_param ={ a:, :b, :c}
module Validation
  ValidationType = Struct.new(:test, :validate, :name_param)

  def self.included(base)
    base.include InstanceMethods
    base.extend ClassMethods

    types = Hash.new do |hash, key|
      hash[key] = ValidationType.new
      hash[key].name_param = []
      hash[key]
    end

    base.instance_variable_set(:@types, types)

    # validate :name, :presence
    types[:presence].test = lambda { |name, _param|
      # param ignoring
      types[:presence].name_param << name
    }

    types[:presence].validate = lambda { |instance|
      types[:presence].name_param.each do |name|
        instance_var = instance.instance_variable_get("@#{name}")
        raise "No presence @#{name}" if instance_var.to_s.empty?
      end
    }

    # validate :number, :format, /[A-Z]{0,3}/
    types[:format].test = lambda { |name, param|
      raise TypeError unless param.is_a?(Regexp)

      types[:format].name_param.push(name, param)
    }

    types[:format].validate = lambda { |instance|
      types[:format].name_param.each_slice(2) do |name, param|
        instance_var = instance.instance_variable_get("@#{name}")
        raise "Format @#{name} is not #{param.inspect}"\
          unless instance_var =~ param
      end
    }

    # validate :station, :type, RailwayStation
    types[:type].test = lambda { |name, param|
      raise TypeError unless param.is_a?(Class)
      types[:type].name_param.push(name, param)
    }

    types[:type].validate = lambda { |instance|
      types[:type].name_param.each_slice(2) do |name, param|
        instance_var = instance.instance_variable_get("@#{name}")
        raise "Type @#{name} is not a #{param}" unless instance_var.is_a?(param)
      end
    }

    define_method(:validate!) do
      types = self.class.instance_variable_get(:@types)
      types.each_value { |value| value.validate.call(self) }
    end
  end

  module ClassMethods
    def validate(name, type, param = nil)
      raise TypeError, 'Validation name is not a Symbol'\
        unless name.is_a?(Symbol)

      raise TypeError, 'Validation type is not a Symbol'\
        unless type.is_a?(Symbol)

      raise 'Unnown validation type' unless @types[type]

      @types[type].test.call(name, param)
    end
  end

  module InstanceMethods
    def valid?
      validate!
      true
    rescue StandardError
      false
    end
  end
end
