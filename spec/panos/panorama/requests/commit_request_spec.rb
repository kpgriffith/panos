require 'spec_helper'
require 'panos/panorama/requests/commit_request'
require 'panos/models/key'
require 'panos'

include Panos
include Panos::Panorama

describe 'Commit Request' do

  before do
    @commitrequest = CommitRequest.new
    # must create the global variables needed to
    $key = Key.new('key')
    $baseurl = 'url'
  end

  context 'commit configs' do
    it 'returns a valid job object' do
      response = "<response status='success'><result><job>1</job></result></response>"
      allow(RestClient::Request).to receive(:execute).and_return(response)
      job = @commitrequest.commit_configs('group')
      expect{job.is_a?(Job)}
    end

    it 'returns nil if no result' do
      response = "<response status='success'></response>"
      allow(RestClient::Request).to receive(:execute).and_return(response)
      job = @commitrequest.commit_configs('group')
      expect{job.nil?}
    end

    it 'returns nil if no job in the result' do
      response = "<response status='success'><result></result></response>"
      allow(RestClient::Request).to receive(:execute).and_return(response)
      job = @commitrequest.commit_configs('group')
      expect{job.nil?}
    end

    it 'throws an exception when there was an error from the firewall' do
      response = "<response status = 'error' code = '403'><result><msg>Invalid credentials.</msg></result></response>"
      allow(RestClient::Request).to receive(:execute).and_return(response)
      expect{@commitrequest.commit_configs('group')}.to raise_error(Exception)
    end

    it 'throws an exception making the rest call' do
      allow(RestClient::Request).to receive(:execute).and_raise(Exception)
      expect{@commitrequest.commit_configs('group')}.to raise_error(Exception)
    end

  end
end
