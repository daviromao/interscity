module ErrorMessage

  ERROR_CODE = {}

  ERROR_CODE[200] = 'OK'

  ERROR_CODE[400] = 'BadRequest'
  ERROR_CODE[401] = 'Unauthorized'
  ERROR_CODE[403] = 'Forbidden'
  ERROR_CODE[404] = 'NotFound'
  ERROR_CODE[422] = 'UnprocessableEntry'
  ERROR_CODE[429] = 'TooManyRequests'

  ERROR_CODE[500] = 'InternalError'
  ERROR_CODE[501] = 'InternalError'
  ERROR_CODE[502] = 'InternalError'
  ERROR_CODE[503] = 'InternalError'

  protected

  def error_payload(message, status)
    payload = {
        code: ERROR_CODE[status],
        message: message
    }

    {json: payload, status: status}
  end


end