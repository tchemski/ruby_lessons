module Validation
  def valid?
    validate!
    true
  rescue StandardError
    false
  end

  protected

  def validate!
    raise 'метод следует переопределить в классе'
  end
end
