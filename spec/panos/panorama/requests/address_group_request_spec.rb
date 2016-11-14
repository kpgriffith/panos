require 'spec_helper'
require 'panos/panorama/requests/address_group_request'
require 'panos/models/key'
require 'panos/panorama/models/address_group'
require 'panos/panorama/models/address'
require 'panos'

include Panos
include Panos::Panorama

describe 'Address Group Request' do

  before do
    @agrequest = AddressGroupRequest.new
    # must create the global variables needed to
    $key = Key.new('key')
    $baseurl = 'url'
  end

  context 'create dynamic address group' do
    it 'succeeds when it creates the group' do
      ag = AddressGroup.new('test', 'Dynamic', 'criteria', 'group')
      response = "<response status = 'success'></response>"
      allow(RestClient::Request).to receive(:execute).and_return(response)
      expect{@agrequest.create(ag)}.to_not raise_error
    end

    it 'throws an exception when there was an error from the firewall' do
      ag = AddressGroup.new('test', 'Dynamic', 'criteria', 'group')
      response = "<response status = 'error' code = '403'><result><msg>Invalid credentials.</msg></result></response>"
      allow(RestClient::Request).to receive(:execute).and_return(response)
      expect{@agrequest.create(ag)}.to raise_error(Exception)
    end

    it 'throws an exception making the rest call' do
      ag = AddressGroup.new('test', 'Dynamic', 'criteria', 'group')
      allow(RestClient::Request).to receive(:execute).and_raise(Exception)
      expect{@agrequest.create(ag)}.to raise_error(Exception)
    end

    it 'throws an arguement error when the address group is not the correct type' do
      expect{@agrequest.create('group-request')}.to raise_error(ArgumentError)
    end

    it 'fails when static and no Address is passed in' do
      ag = AddressGroup.new('test', 'Static', 'criteria', 'group')
      allow(RestClient::Request).to receive(:execute).and_raise(Exception)
      expect{@agrequest.create(ag)}.to raise_error(Exception)
    end

    it 'fails when static and the address passed in is not an Address type' do
      ag = AddressGroup.new('test', 'Static', 'criteria', 'group')
      allow(RestClient::Request).to receive(:execute).and_raise(Exception)
      expect{@agrequest.create(ag, 'NotAnAddress')}.to raise_error(Exception)
    end

    it 'succeeds when static' do
      ag = AddressGroup.new('test', 'Static', 'criteria', 'group')
      address = Address.new('name','IP_NETMASK','1.1.1.1','group')
      response = "<response status = 'success'></response>"
      allow(RestClient::Request).to receive(:execute).and_return(response)
      expect{@agrequest.create(ag, address)}.to_not raise_error
    end

  end

  context 'delete group' do
    it 'succeeds when it deletes the group' do
      ag = AddressGroup.new('test', 'Dynamic', 'criteria', 'group')
      response = "<response status = 'success'></response>"
      allow(RestClient::Request).to receive(:execute).and_return(response)
      expect{@agrequest.delete(ag)}.to_not raise_error
    end

    it 'throws an exception when there was an error from the firewall' do
      ag = AddressGroup.new('test', 'Dynamic', 'criteria', 'group')
      response = "<response status = 'error' code = '403'><result><msg>Invalid credentials.</msg></result></response>"
      allow(RestClient::Request).to receive(:execute).and_return(response)
      expect{@agrequest.delete(ag)}.to raise_error(Exception)
    end

    it 'throws an exception making the rest call' do
      ag = AddressGroup.new('test', 'Dynamic', 'criteria', 'group')
      allow(RestClient::Request).to receive(:execute).and_raise(Exception)
      expect{@agrequest.delete(ag)}.to raise_error(Exception)
    end

    it 'throws an arguement error when the address group is not the correct type' do
      expect{@agrequest.delete('group-request')}.to raise_error(ArgumentError)
    end

  end

end
