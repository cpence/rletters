# -*- encoding : utf-8 -*-
require 'net/http'

# Ruby's standard networking module
module Net
  # Ruby's standard HTTP connection class
  class HTTP
    # Exceptions that can be raised by Net:HTTP methods like #get and #post
    #
    # @return [Array<Exceptions>] list of exceptions
    EXCEPTIONS = [
      Errno::ECONNREFUSED,
      Errno::ECONNRESET,
      Errno::EHOSTUNREACH,
      Errno::EINVAL,
      Errno::EPIPE,
      Errno::ETIMEDOUT,
      EOFError,
      Net::HTTPBadResponse,
      Net::HTTPHeaderSyntaxError,
      Net::ProtocolError,
      SocketError,
      Timeout::Error
    ] unless const_defined?(:EXCEPTIONS)
  end
end
