module Acсessors
  def attr_accessor_with_history(*names)
    names.each do |name|
      raise TypeError, 'Accessor name is not a Symbol'\
        unless name.is_a?(Symbol)

      name_var = "@#{name}"
      history_var = "#{name_var}_history".to_sym

      # @name getter
      define_method(name) do
        instance_variable_get(name_var)
      end

      # @name_history getter
      define_method("#{name}_history") do
        instance_variable_get(history_var)\
        || instance_variable_set(history_var, [])
      end

      # @name setter
      define_method("#{name}=") do |value|
        send("#{name}_history")
          .send(:<<, value)
        instance_variable_set(name_var, value)
      end
    end
  end

  def strong_attr_accessor(names)
    names.each_pair do |name, klass|
      raise TypeError, 'Accessor name is not a Symbol'\
        unless name.is_a?(Symbol)

      raise TypeError, 'Accessor class is not a Class'\
        unless klass.is_a?(Class)

      name_var = "@#{name}"

      # @name getter
      define_method(name) do
        instance_variable_get(name_var)
      end

      # @name setter
      define_method("#{name}=") do |value|
        raise TypeError, "Class #{name_var} is not a #{klass}"\
          unless value.is_a?(klass)

        instance_variable_set(name_var, value)
      end
    end
  end
end
