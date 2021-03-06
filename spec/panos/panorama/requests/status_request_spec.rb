require 'spec_helper'
require 'panos/panorama/requests/status_request'
require 'panos/panorama/models/status'
require 'panos/models/key'
require 'panos/models/job'
require 'panos'

include Panos
include Panos::Panorama

describe 'Status Request' do

  before do
    @request = StatusRequest.new
    # must create the global variables needed to
    $key = Key.new('key')
    $baseurl = 'url'
  end

  context 'get status' do
    it 'returns a valid address object for ip_netmask with a tag if found' do
      response = "<response status='success'><result><job status='FIN' result='OK' progress='100'></job></result></response>"
      allow(RestClient::Request).to receive(:execute).and_return(response)
      status = @request.get_status(1)
      expect{status.is_a?(Status)}
    end

    it 'returns a valid address object for ip_netmask with a tag if found with details and devices' do
      response = "<response status='success'><result><job status='FIN' result='OK' progress='100'><details><line>message</line></details><device><entry>1</entry><entry>2</entry></device></job></result></response>"
      allow(RestClient::Request).to receive(:execute).and_return(response)
      status = @request.get_status(1)
      expect{status.is_a?(Status)}
    end

    it 'throws an exception when there was an error from the firewall' do
      response = "<response status = 'error' code = '403'><result><msg>Invalid credentials.</msg></result></response>"
      allow(RestClient::Request).to receive(:execute).and_return(response)
      expect{@request.get_status(1)}.to raise_error(Exception)
    end

    it 'throws an exception making the rest call' do
      allow(RestClient::Request).to receive(:execute).and_raise(Exception)
      expect{@request.get_status(1)}.to raise_error(Exception)
    end

  end

  context 'job complete' do
    it 'fails if the arguement is not a Job type' do
      expect{@request.job_complete?('job')}.to raise_error(ArgumentError)
    end

    it 'returns false when panorama job status is not FIN' do
      job = Job.new(1)
      status = Status.new('PEND','PEND',0)
      allow(@request).to receive(:get_status).and_return(status)
      bool = @request.job_complete?(job)
      expect{bool == false}
    end

    it 'returns false when panorama job progress is not 100' do
      job = Job.new(1)
      status = Status.new('FIN','PEND',0)
      allow(@request).to receive(:get_status).and_return(status)
      bool = @request.job_complete?(job)
      expect{bool == false}
    end

    it 'returns false when panorama job result is not OK' do
      job = Job.new(1)
      status = Status.new('FIN','PEND',100)
      allow(@request).to receive(:get_status).and_return(status)
      bool = @request.job_complete?(job)
      expect{bool == false}
    end

    it 'returns true when panorama job is complete but no devices' do
      job = Job.new(1)
      status = Status.new('FIN','OK',100)
      allow(@request).to receive(:get_status).and_return(status)
      bool = @request.job_complete?(job)
      expect{bool == true}
    end

    it 'returns true when panorama job is complete but no devices' do
      job = Job.new(1)
      status = Status.new('FIN','OK',100, 'message')
      allow(@request).to receive(:get_status).and_return(status)
      bool = @request.job_complete?(job)
      expect{bool == true}
    end

  end
end
