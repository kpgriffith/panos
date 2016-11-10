require 'panos/models/key'

module Panos
  class KeyRequest

    def get(endpoint, user, password)
      begin
        key_response = RestClient::Request.execute(
          :method => :get,
          :verify_ssl => false,
          :url => endpoint,
          :headers => {
            :params => {
              :type => 'keygen',
              :user => user,
              :password => password
            }
          }
        )
        # parse the xml to get the key
        key_hash = Crack::XML.parse(key_response)
        raise Exception.new("PANOS Error getting key: #{key_hash['response']['result']['msg']}") if key_hash['response']['status'] == 'error'

        key = Key.new(key_hash['response']['result']['key'])
        return key
      rescue => e
        raise Exception.new("Excpetion getting key: #{e}")
      end
    end

  end
end
