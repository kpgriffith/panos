require 'spec_helper'
require 'panos/panorama/models/status'

include Panos::Panorama

describe 'Status' do
  it 'succeeds when all is right' do
    status = Status.new('status', 'result', 100, 'message', 'device_entry')
    expect{status}.to be_a Status
  end

  it 'fails when status is nil' do
    expect{Status.new(nil, 'result', 100)}.to raise_error(ArgumentError)
  end

  it 'fails when result is nil' do
    expect{Status.new('status', nil, 100)}.to raise_error(ArgumentError)
  end

  it 'fails when progress is nil' do
    expect{Status.new('status', 'result', nil)}.to raise_error(ArgumentError)
  end

  it 'fails when progress is not an Integer' do
    expect{Status.new('status', 'result', 'hello')}.to raise_error(ArgumentError)
  end
end
