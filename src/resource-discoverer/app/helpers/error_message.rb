# frozen_string_literal: true

# Global constants for error messages
module ErrorMessage
  ERROR_CODE = {
    200 => 'OK',

    400 => 'Bad Request',
    401 => 'Unauthorized',
    403 => 'Forbidden',
    404 => 'Not Found',
    422 => 'Unprocessable Entry',
    429 => 'Too Many Requests',

    500 => 'Internal Server Error',
    501 => 'Not Implemented',
    502 => 'Bad Gateway',
    503 => 'Service Unavailable'
  }.freeze

  protected

  def error_payload(message, status)
    payload = {
      code: ERROR_CODE[status],
      message: message
    }

    { json: payload, status: status }
  end
end
