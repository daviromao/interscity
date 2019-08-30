# frozen_string_literal: true

class ApplicationController < ActionController::API
  ERROR_CODE = {
    200 => 'OK',

    400 => 'BadRequest',
    401 => 'Unauthorized',
    403 => 'Forbidden',
    404 => 'NotFound',
    405 => 'MethodNotAllowed',
    422 => 'UnprocessableEntry',
    429 => 'TooManyRequests',

    500 => 'InternalError',
    501 => 'NotImplemented',
    502 => 'BadGateway',
    503 => 'ServiceUnavailable'
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
