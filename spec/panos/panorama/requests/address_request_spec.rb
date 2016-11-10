require 'spec_helper'
require 'panos/panorama/requests/address_request'
require 'panos/models/key'

include Panos::Panorama

describe 'Address Request' do

  context 'get address' do
    it 'returns a valid address object if found'

    it 'returns a nil if no address was found'

    it 'throws an exception when there was an error from the firewall'

  end

  context 'address exists' do
    it 'returns true when the address is not nil'

    it 'returns false when the address is nil'

  end

  context 'update address' do
    it 'fails if the arguement is not an Address type'

    it 'throws an exception when there was an error from the firewall'

  end

  context 'create address' do
    it 'succeeds when it creates the address'

    it 'throws an exception when there was an error from the firewall'

  end

  context 'delete address' do
    it 'succeeds when it delets the address'

    it 'throws an exception when there was an error from the firewall'

  end

  context 'get all addresses with tag name' do
    it 'returns all the addresses with the tag name'

    it 'returns nil for no addresses found with the tag name'

    it 'throws an exception when there was an error from the firewall'

  end

end
