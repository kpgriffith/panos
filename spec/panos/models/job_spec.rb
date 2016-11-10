require 'spec_helper'
require 'panos/models/job'

include Panos

describe 'Job' do
  context 'value' do
    it 'succeeds when not nil' do
      job = Job.new(1)
      expect{job}.to be_a Job
    end

    it 'fails when nil' do
      expect{Job.new(nil)}.to raise_error(ArgumentError)
    end

    it 'fails when value is not an Integer' do
      expect{Job.new('1')}.to raise_error(ArgumentError)
    end
  end
end
