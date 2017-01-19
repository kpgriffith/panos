require 'panos/panorama/models/address_group'
require 'panos/panorama/models/address'
require 'panos/panorama/requests/address_group_request'
require 'panos/panorama/requests/address_request'
require 'panos/panorama/requests/tag_request'

module Panos
  module Panorama
    class Client

      def create_dag_with_addresses(tag, device_groups, address_group, addresses)

        device_groups.each do |device_group|
          # create the tag that will be used
          tag_request = TagRequest.new
          tag_request.create(tag, device_group)

          # create a DAG
          dag_request = AddressGroupRequest.new
          dag_request.create(address_group)

          # create the address
          address_request = AddressRequest.new
          addresses.each do |address|
            address_request.create(address)
          end
        end

      end

    end
  end
end
