require 'panos/models/key'

module Panos
  module Panorama

    class TagRequest

      def create(tag_name, device_group)
        begin
          tag_response = RestClient::Request.execute(
            :method => :post,
            :verify_ssl => false,
            :url => $baseurl,
            :headers => {
              :params => {
                :key => $key.value,
                :type => 'config',
                :action => 'set',
                :xpath => "/config/devices/entry[@name='localhost.localdomain']/device-group/entry[@name='#{device_group}']/tag",
                :element => "<entry name='#{tag_name}'/>"
              }
            }
          )
          create_hash = Crack::XML.parse(tag_response)
          raise Exception.new("PANOS Error creating address: #{create_hash['response']['msg']}") if create_hash['response']['status'] == 'error'
        rescue => e
          raise Exception.new("Exception creating the tag: #{e} ")
        end
      end

    end

  end
end
