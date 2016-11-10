require 'spec_helper'
require 'panos/panorama/requests/status_request'
require 'panos/models/key'

include Panos::Panorama

describe 'Status Request' do

  context 'get status' do
    it 'returns a valid status object'

    it 'throws an exception when there was an error from the firewall'

  end

  context 'job complete' do
    it 'returns a false when the job is not complete'

    it 'returns a true when the job is complete'

    it 'throws an exception if the job is completed, but has a bad return code'

  end
end
