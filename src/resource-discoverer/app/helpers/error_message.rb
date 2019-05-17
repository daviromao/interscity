# Global constants for error messages
module ErrorMessage
  ERROR_CODE = {}

  ERROR_CODE[200] = 'OK'

  ERROR_CODE[400] = 'Bad Request'
  ERROR_CODE[401] = 'Unauthorized'
  ERROR_CODE[403] = 'Forbidden'
  ERROR_CODE[404] = 'Not Found'
  ERROR_CODE[422] = 'Unprocessable Entry'
  ERROR_CODE[429] = 'Too Many Requests'

  ERROR_CODE[500] = 'Internal Server Error'
  ERROR_CODE[501] = 'Not Implemented'
  ERROR_CODE[502] = 'Bad Gateway'
  ERROR_CODE[503] = 'Service Unavailable'

  protected

  def error_payload(message, status)
    payload = {
      code: ERROR_CODE[status],
      message: message
    }

    { json: payload, status: status }
  end
end
