module Descendants
  def inherited(subclass)
    descendants << subclass
  end

  def descendants
    @descendants ||= []
  end
end
