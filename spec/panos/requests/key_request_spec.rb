require 'spec_helper'
require 'panos/models/key'
require 'panos/requests/key_request'
require 'panos'

include Panos

describe 'Key Request' do

  before do
    @keyrequest = KeyRequest.new
  end

  context 'get key' do
    it 'returns a response' do
      response = "<response status = 'success'><result><key>mykey</key></result></response>"
      allow(RestClient::Request).to receive(:execute).and_return(response)
      expect{@keyrequest.get('url','username','password')}.to be_a Key
    end

    it 'returns an error' do
      allow(RestClient::Request).to receive(:execute).and_raise(Exception)
      expect{@keyrequest.get('url','user','password')}.to raise_error(Exception)
    end

    it 'returns an error' do
      response = "<response status = 'error' code = '403'><result><msg>Invalid credentials.</msg></result></response>"
      allow(RestClient::Request).to receive(:execute).and_return(response)
      expect{@keyrequest.get('url','user','password')}.to raise_error(Exception)
    end
  end
end
