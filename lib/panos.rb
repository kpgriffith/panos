require 'uri'
require 'openssl'
require 'base64'
require 'net/https'
require 'net/http'
require 'rest-client'
require 'json'
require 'crack'
require 'panos/requests/key_request'

module Panos

  def get_key(endpoint, user, password)
    fail ArgumentError, 'endpoint cannot be nil' if endpoint.nil?
    fail ArgumentError, 'user cannot be nil' if user.nil?
    fail ArgumentError, 'password cannot be nil' if password.nil?

    key_request = KeyRequest.new
    $key = key_request.get(endpoint, user, password)
    $baseurl = endpoint
  end

  module_function :get_key

end
