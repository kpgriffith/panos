require 'spec_helper'
require 'panos/panorama/requests/tag_request'
require 'panos/models/key'
require 'panos'

include Panos
include Panos::Panorama

describe 'Tag Request' do

  before do
    @tagrequest = TagRequest.new
    # must create the global variables needed to
    $key = Key.new('key')
    $baseurl = 'url'
  end

  context 'create tag' do
    it 'succeeds when it creates the tag' do
      response = "<response status = 'success'></response>"
      allow(RestClient::Request).to receive(:execute).and_return(response)
      expect{@tagrequest.create('name','group')}.to_not raise_error
    end

    it 'throws an exception when there was an error from the firewall' do
      response = "<response status = 'error' code = '403'><result><msg>Invalid credentials.</msg></result></response>"
      allow(RestClient::Request).to receive(:execute).and_return(response)
      expect{@tagrequest.create('name','group')}.to raise_error(Exception)
    end

    it 'throws an exception making the rest call' do
      allow(RestClient::Request).to receive(:execute).and_raise(Exception)
      expect{@tagrequest.create('name','group')}.to raise_error(Exception)
    end

  end

end
