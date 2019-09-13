# frozen_string_literal: true

class String
  # Check that given string is a Float.
  def float?
    true if Float(self)
  rescue StandardError
    false
  end

  # Check that given string is an Integer and
  # verify if it is positive ahead.
  def positive_int?
    int = begin
            Integer(self)
          rescue StandardError
            false
          end
    begin
      true if int >= 0
    rescue StandardError
      false
    end
  end
end
