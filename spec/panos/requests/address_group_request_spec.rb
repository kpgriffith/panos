require 'spec_helper'
require 'panos/requests/address_group_request'
require 'panos/models/key'

describe 'Address Group Request' do
  context 'initialize' do
    it 'fails when key is nil' do
      expect{AddressRequest.new('url', nil)}.to raise_error(ArgumentError)
    end

    it 'fails when key is not of type Key' do
      expect{AddressRequest.new('url', 'userid')}.to raise_error(ArgumentError)
    end

    it 'succeeds when key is of type Key' do
      key = Key.new('value')
      address_req = AddressRequest.new('url', key)
      expect(address_req).to be_a AddressRequest
    end

    it 'fails when url is nil' do
      key = Key.new('value')
      expect{AddressRequest.new(nil, key)}.to raise_error(ArgumentError)
    end
  end

  context 'create dynamic address group' do
    it 'succeeds when it creates the group'

    it 'throws an exception when there was an error from the firewall'

  end

  context 'delete group' do
    it 'succeeds when it deletes the group'

    it 'throws an exception when there was an error from the firewall'

  end

end
