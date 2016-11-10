require 'panos/models/key'
require 'panos/models/job'

module Panos
  module Panorama

    class CommitRequest

      def commit_configs(device_group)
        begin
          commit_response = RestClient::Request.execute(
            :method => :post,
            :verify_ssl => false,
            :url => @baseurl,
            :headers => {
              :params => {
                :key => @key.value,
                :type => 'commit',
                :action => 'all',
                :cmd => "<commit-all><shared-policy><device-group><entry name=\"#{device_group}\"/></device-group></shared-policy></commit-all>"
              }
            }
          )
          commit_hash = Crack::XML.parse(commit_response)
          if commit_hash['response']['status'] == 'error'
            if commit_hash['response']['code'].to_i == 13
              # a commit is already in progress, need to sleep and try again
              sleep(30)
              commit_configs(device_group)
            else
              raise Exception.new("PANOS Error committing: #{commit_hash['response']['msg']}")
            end
          end

          if commit_hash['response'].has_key?('result')
            # if job exists in the payload that means a job was submitted to commit the changes.
            if commit_hash['response']['result'].has_key?('job')
              job = Job.new(commit_hash['response']['result']['job'].to_i)
              return job
            else
              return nil
            end
          else
            return nil
          end
        rescue => e
          raise Exception.new("Exception committing PANOS job: #{e}")
        end
      end

    end

  end
end
