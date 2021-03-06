require 'resolv'

module Panos
  module Panorama

    class Address

      attr_reader :name, :type, :tags, :device_group

      attr_accessor :address

      module Type
        IP_NETMASK = 'IP_Netmask'
        IP_RANGE = 'IP_Range'
        FQDN = 'FQDN'
      end

      def initialize(name, type, address, device_group, tags = nil)
        fail ArgumentError, 'name cannot be nil' if name.nil?
        fail ArgumentError, 'type cannot be nil' if type.nil?
        fail ArgumentError, "type, #{type}, is not valid" if !is_valid_type?(type)
        fail ArgumentError, 'device_group cannot be nil' if device_group.nil?
        fail ArgumentError, 'address cannot be nil' if address.nil?
        fail ArgumentError, 'address is not the correct format' if !is_valid_address?(type,address)

        super()
        @name = name
        @type = type
        @address = address
        @tags = tags
        @device_group = device_group
      end

      def is_valid_type?(type)
        if ( (Type::IP_NETMASK.casecmp(type) == 0) ||
             (Type::IP_RANGE.casecmp(type) == 0) ||
             (Type::FQDN.casecmp(type) == 0) )
          return true
        else
          return false
        end
      end

      def is_valid_address?(type, value)
        case type
          when 'IP_NETMASK'
            if (value =~ Resolv::IPv4::Regex || value =~ Resolv::IPv6::Regex)
              return true
            end
          when 'IP_RANGE'
            return true
          when 'FQDN'
            return true
        end
        return false
      end

      # override the == method to check if two Address objects equal based on name
      def ==(another_address)
        self.name == another_address.name
      end

    end

  end
end
