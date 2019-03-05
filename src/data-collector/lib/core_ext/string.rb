class String

  # Check that given string is a Float.
  def is_float?
    true if Float(self) rescue false
  end

  # Check that given string is an Integer and
  # verify if it is positive ahead.
  def is_positive_int?
    int = Integer(self) rescue false
    true if int >= 0 rescue false
  end
end
