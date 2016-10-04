require 'panos/models/key'
require 'panos/models/address'
# require File.expand_path('../../models/key.rb', __FILE__)
# require File.expand_path('../../models/address.rb', __FILE__)

# This class provides functions for updating the address object on a PANOS firewall device
class AddressRequest

  attr_accessor :address

  # initialize the class making sure we have a URL endpoint and a KEY to use when communicating
  # to the firewall device
  def initialize(url, key)
    fail ArgumentError, 'url cannot be nil' if url.nil?
    fail ArgumentError, 'key cannot be nil' if key.nil?
    fail ArgumentError, 'key must be of type Key' if !key.is_a? Key

    @baseurl = url
    @key = key
  end

  # TODO need to add logic for the different types of address.
  # Update will update the address in the firewall device
  # right now it just updates the IP address
  def update(address, device_group)
    fail ArgumentError, 'address must be of type Address' if !address.is_a? Address

    begin
    	set_address_response = RestClient::Request.execute(
    		:method => :post,
    		:verify_ssl => false,
    		:url => @baseurl,
    		:headers => {
    			:params => {
    				:key => @key.value,
    				:type => 'config',
    				:action => 'edit',
    				:xpath => "/config/devices/entry[@name='localhost.localdomain']/device-group/entry[@name='#{device_group}']/address/entry[@name='#{address.name}']/ip-netmask",
    				:element => "<ip-netmask>#{address.address}</ip-netmask>"
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
  def get(name, device_group)
    begin
    	get_response = RestClient::Request.execute(
    		:method => :get,
    		:verify_ssl => false,
    		:url => @baseurl,
    		:headers => {
    			:params => {
    				:key => @key.value,
    				:type => 'config',
    				:action => 'get',
    				:xpath => "/config/devices/entry[@name='localhost.localdomain']/device-group/entry[@name='#{device_group}']/address/entry[@name='#{name}']"
    			}
    		}
    	)
      get_hash = Crack::XML.parse(get_response)
      raise Exception.new("PANOS error getting address: #{get_hash['response']['msg']}") if get_hash['response']['status'] == 'error'
      # if the entry isn't found, the response from PANOS isn't an error, the result attribute
      # in the XML response is nil
      if !get_hash['response']['result'].nil?
        entry = get_hash['response']['result']['entry']
        # tag is optional so we have to check for nil
        tag = !entry['tag'].nil? ? nil : entry['tag']['member']
        @address = Address.new(entry['name'], 'IP_NETMASK', entry['ip_netmask'], tag)
        return @address
      else
        return nil
      end
    rescue => e
      raise Exception.new("Exception getting address: #{e}")
    end
  end

  def exists?(name, device_group)
    address = get(name)
    bool = !address.nil? ? true : false
    return bool
  end

  def create(name, ip, tag, device_group)
    begin
    	set_address_response = RestClient::Request.execute(
    		:method => :post,
    		:verify_ssl => false,
    		:url => @baseurl,
    		:headers => {
    			:params => {
    				:key => @key.value,
    				:type => 'config',
    				:action => 'set',
    				:xpath => "/config/devices/entry[@name='localhost.localdomain']/device-group/entry[@name='#{device_group}']/address",
    				:element => "<entry name='#{name}'><ip-netmask>#{ip}</ip-netmask><tag><member>#{tag}</member></tag></entry>"
    			}
    		}
    	)
      create_hash = Crack::XML.parse(set_address_response)
      raise Exception.new("PANOS Error creating address: #{create_hash['response']['msg']}") if create_hash['response']['status'] == 'error'
    rescue => e
      raise Exception.new("Exception Creating address: #{e}")
    end
  end

  def delete(name, device_group)
    begin
    	delete_address_response = RestClient::Request.execute(
    		:method => :post,
    		:verify_ssl => false,
    		:url => @baseurl,
    		:headers => {
    			:params => {
    				:key => @key.value,
    				:type => 'config',
    				:action => 'delete',
            :xpath => "/config/devices/entry[@name='localhost.localdomain']/device-group/entry[@name='#{device_group}']/address/entry[@name='#{name}']"
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
        :url => @baseurl,
        :headers => {
          :params => {
            :key => @key.value,
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
      if !get_all_hash['response']['result'].nil?
        entries = get_all_hash['response']['result']['address']['entry']
        entries.each do |entry|
          # tag is optional so we have to check for nil
          tag = nil
          if entry.has_key?('tag')
            tag = entry['tag']['member']
          end
          # add the address to an array if the tags are equal
          if !tag.nil? && tag == tag_name
            address_array.push(Address.new(entry['name'], 'IP_NETMASK', entry['ip_netmask'], tag))
          end
        end
      end
      address_array
    rescue => e
      raise Exception.new("Exception getting address: #{e}")
    end
  end

end
