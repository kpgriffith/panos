require 'panos/models/key'
require 'panos/panorama/models/address_group'
require 'panos/panorama/models/address'

module Panos
  module Panorama
    class AddressGroupRequest

      def create(address_group, address = nil)
        fail ArgumentError, 'address_group must be of type AddressGroup' if !address_group.is_a? AddressGroup

        if address_group.type =~ /Dynamic/
        	element = "<entry name='#{address_group.name}'><dynamic><filter>'#{address_group.criteria}'</filter></dynamic></entry>"
        else
          # this is a static type address group, it requires an address to add to the group
          raise Exception.new('Address is required to configure a STATIC type address group') if address.nil?
          raise Exception.new('Address must be of type Address') if !address.is_a? Address
          element = "<entry name='#{address_group.name}'<static><member>#{address.name}</member></static>"
        end

        begin
        	set_ag_response = RestClient::Request.execute(
        		:method => :post,
        		:verify_ssl => false,
        		:url => @baseurl,
        		:headers => {
        			:params => {
        				:key => @key.value,
        				:type => 'config',
        				:action => 'set',
        				:xpath => "/config/devices/entry[@name='localhost.localdomain']/device-group/entry[@name='#{address_group.device_group}']/address-group",
        				:element => element
        			}
        		}
        	)
          dag_hash = Crack::XML.parse(set_ag_response)
          raise Exception.new("PANOS Error creating a DAG: #{dag_hash['response']['msg']}") if dag_hash['response']['status'] == 'error'
        rescue => e
          raise Exception.new("Exception creating DAG: #{e} ")
        end
      end

      def delete(address_group)
        fail ArgumentError, 'address_group must be of type AddressGroup' if !address_group.is_a? AddressGroup

        begin
        	delete_ag_response = RestClient::Request.execute(
        		:method => :post,
        		:verify_ssl => false,
        		:url => @baseurl,
        		:headers => {
        			:params => {
        				:key => @key.value,
        				:type => 'config',
        				:action => 'delete',
                :xpath => "/config/devices/entry[@name='localhost.localdomain']/device-group/entry[@name='#{address_group.device_group}']/address-group/entry[@name='#{address_group.name}']"
        			}
        		}
        	)
          dag_hash = Crack::XML.parse(delete_ag_response)
          raise Exception.new("PANOS Error deleting a DAG: #{dag_hash['response']['msg']}") if dag_hash['response']['status'] == 'error'
        rescue => e
          raise Exception.new("Exception deleting DAG: #{e} ")
        end
      end

    end
  end
end
