require 'panos/models/key'
require 'panos/panorama/models/address'
require 'panos'

# This class provides functions for updating the address object on a PANOS firewall device
module Panos
  module Panorama
    class AddressRequest

      # Update will update the address in the firewall device
      # right now it just updates the IP address
      def update(address)
        fail ArgumentError, 'address must be of type Address' unless address.is_a? Address

        if 'IP_Netmask'.casecmp(address.type) == 0
          xpath = "/config/devices/entry[@name='localhost.localdomain']/device-group/entry[@name='#{address.device_group}']/address/entry[@name='#{address.name}']/ip-netmask"
          element = "<ip-netmask>#{address.address}</ip-netmask>"
        elsif 'IP_Range'.casecmp(address.type) == 0
          xpath = "/config/devices/entry[@name='localhost.localdomain']/device-group/entry[@name='#{address.device_group}']/address/entry[@name='#{address.name}']/ip-range"
          element = "<ip-range>#{address.address}</ip-range>"
        else   # fqdn scenario
          xpath = "/config/devices/entry[@name='localhost.localdomain']/device-group/entry[@name='#{address.device_group}']/address/entry[@name='#{address.name}']/fqdn"
          element = "<fqdn>#{address.address}</fqdn>"
        end

        begin
        	set_address_response = RestClient::Request.execute(
        		:method => :post,
        		:verify_ssl => false,
        		:url => $baseurl,
        		:headers => {
        			:params => {
        				:key => $key.value,
        				:type => 'config',
        				:action => 'edit',
        				:xpath => xpath,
        				:element => element
        			}
        		}
        	)
          update_hash = Crack::XML.parse(set_address_response)
          # It might return from the firewall call successfully, but with an error, so we need to check that.
          raise Exception.new("PANOS error updating address: #{update_hash['response']['msg']}") if update_hash['response']['status'] == 'error'
        rescue => e
          raise Exception.new("Exception updating the address: #{e} ")
        end
      end

      # get returns the Address from the name of the address given.
      def get(address)
        fail ArgumentError, 'address must be of type Address' unless address.is_a? Address

        begin
        	get_response = RestClient::Request.execute(
        		:method => :get,
        		:verify_ssl => false,
        		:url => $baseurl,
        		:headers => {
        			:params => {
        				:key => $key.value,
        				:type => 'config',
        				:action => 'get',
        				:xpath => "/config/devices/entry[@name='localhost.localdomain']/device-group/entry[@name='#{address.device_group}']/address/entry[@name='#{address.name}']"
        			}
        		}
        	)
          get_hash = Crack::XML.parse(get_response)
          raise Exception.new("PANOS error getting address: #{get_hash['response']['msg']}") if get_hash['response']['status'] == 'error'
          # if the entry isn't found, the response from PANOS isn't an error, the result attribute
          # in the XML response is nil
          if get_hash['response'].has_key?('result')
            entry = get_hash['response']['result']['entry']

            # tag is optional so we have to check for nil
            tag = !entry.has_key?('tag') ? nil : entry['tag']['member']

            if entry.has_key?('ip_netmask')
              @address = Address.new(entry['name'], 'IP_NETMASK', entry['ip_netmask'], entry['loc'], tag)
              return @address
            elsif entry.has_key?('ip_range')
              @address = Address.new(entry['name'], 'IP_RANGE', entry['ip_range'], entry['loc'], tag)
              return @address
            elsif entry.has_key?('fqdn')
              @address = Address.new(entry['name'], 'FQDN', entry['fqdn'], entry['loc'], tag)
              return @address
            else
              #must be a new type not yet implemented.
              return nil
            end
          else
            return nil
          end
        rescue => e
          raise Exception.new("Exception getting address: #{e}")
        end
      end

      def exists?(address)
        address = get(address)
        bool = !address.nil? ? true : false
        return bool
      end

      def create(address)
        fail ArgumentError, 'address must be of type Address' unless address.is_a? Address

        if 'IP_Netmask'.casecmp(address.type) == 0
          element = "<entry name='#{address.name}'><ip-netmask>#{address.address}</ip-netmask><tag><member>#{address.tags}</member></tag></entry>"
        elsif 'IP_Range'.casecmp(address.type) == 0
          element = "<entry name='#{address.name}'><ip-range>#{address.address}</ip-range><tag><member>#{address.tags}</member></tag></entry>"
        else   # fqdn scenario
          element = "<entry name='#{address.name}'><fqdn>#{address.address}</fqdn><tag><member>#{address.tags}</member></tag></entry>"
        end

        begin
        	set_address_response = RestClient::Request.execute(
        		:method => :post,
        		:verify_ssl => false,
        		:url => $baseurl,
        		:headers => {
        			:params => {
        				:key => $key.value,
        				:type => 'config',
        				:action => 'set',
        				:xpath => "/config/devices/entry[@name='localhost.localdomain']/device-group/entry[@name='#{address.device_group}']/address",
        				:element => element
        			}
        		}
        	)
          create_hash = Crack::XML.parse(set_address_response)
          raise Exception.new("PANOS Error creating address: #{create_hash['response']['msg']}") if create_hash['response']['status'] == 'error'
        rescue => e
          raise Exception.new("Exception Creating address: #{e}")
        end
      end

      def delete(address)
        fail ArgumentError, 'address must be of type Address' unless address.is_a? Address

        begin
        	delete_address_response = RestClient::Request.execute(
        		:method => :post,
        		:verify_ssl => false,
        		:url => $baseurl,
        		:headers => {
        			:params => {
        				:key => $key.value,
        				:type => 'config',
        				:action => 'delete',
                :xpath => "/config/devices/entry[@name='localhost.localdomain']/device-group/entry[@name='#{address.device_group}']/address/entry[@name='#{address.name}']"
        			}
        		}
        	)
          delete_hash = Crack::XML.parse(delete_address_response)
          raise Exception.new("PANOS Error deleting address: #{delete_hash['response']['msg']}") if delete_hash['response']['status'] == 'error'
        rescue => e
          raise Exception.new("Exception Deleting address: #{e}")
        end
      end

      def get_all_for_tag(tag_name, device_group)
        address_array = []
        begin
          get_response = RestClient::Request.execute(
            :method => :get,
            :verify_ssl => false,
            :url => $baseurl,
            :headers => {
              :params => {
                :key => $key.value,
                :type => 'config',
                :action => 'get',
                :xpath => "/config/devices/entry[@name='localhost.localdomain']/device-group/entry[@name='#{device_group}']/address"
              }
            }
          )
          get_all_hash = Crack::XML.parse(get_response)
          raise Exception.new("PANOS error getting address: #{get_all_hash['response']['msg']}") if get_all_hash['response']['status'] == 'error'
          # if the entry isn't found, the response from PANOS isn't an error, the result attribute
          # in the XML response is nil
          if get_all_hash['response'].has_key?('result') && !get_all_hash['response']['result'].nil?
            entries = get_all_hash['response']['result']['address']['entry']
            entries.each do |entry|
              # tag is optional so we have to check for nil
              tag = nil
              if entry.has_key?('tag')
                tag = entry['tag']['member']
              end
              # add the address to an array if the tags are equal
              if !tag.nil? && tag == tag_name
                if entry.has_key?('ip_netmask')
                  address_array.push(Address.new(entry['name'], 'IP_NETMASK', entry['ip_netmask'], entry['loc'], tag))
                elsif entry.has_key?('ip_range')
                  address_array.push(Address.new(entry['name'], 'IP_RANGE', entry['ip_range'], entry['loc'], tag))
                elsif entry.has_key?('fqdn')
                  address_array.push(Address.new(entry['name'], 'FQDN', entry['fqdn'], entry['loc'], tag))
                end
              end
            end
          end
          address_array
        rescue => e
          raise Exception.new("Exception getting address: #{e}")
        end
      end

    end
  end
end
