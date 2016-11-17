require 'panos/models/key'
require 'panos/models/job'
require 'panos/panorama/models/status'
require 'panos'

module Panos
  module Panorama

    class StatusRequest

      def get_status(jobid)
        begin
          status_response = RestClient::Request.execute(
            :method => :post,
            :verify_ssl => false,
            :url => $baseurl,
            :headers => {
              :params => {
                :key => $key.value,
                :type => 'op',
                :cmd => "<show><jobs><id>#{jobid}</id></jobs></show>"
              }
            }
          )
          status_hash = Crack::XML.parse(status_response)
          raise Exception.new("PANOS Error getting status: #{status_hash['response']['msg']}") if status_hash['response']['status'] == 'error'
          job = status_hash['response']['result']['job']

          message = job['details'].nil? ? nil : job['details']['line']
          device_entries = job['devices'].nil? ? nil : job['devices']['entry']

          status = Status.new(job['status'], job['result'], job['progress'].to_i, message, device_entries)
          return status
        rescue => e
          raise Exception.new("Exception getting job status: #{e}")
        end
      end

      def job_complete?(job)
        fail ArgumentError, 'job must be of type Panos::Job' unless job.is_a? Job

        status = get_status(job.id)
        if status.status == 'FIN' && status.progress == 100
          if status.result == 'OK'
            if status.device_entry.nil?
              return true
            else
              # Panorama is done updating, let's check the firewall devices it submitted commits to
              if status.device_entry.is_a? Array
                complete = true
                error = false
                error_msg = ''
                status.device_entry.each do |entry|
                  if entry['result'] =~ /FAIL/
                    error = true
                    error_msg = "Job completed but device commit failed: #{entry['details']['msg']['errors']['line']}"
                  elsif entry['result'] =~ /PEND/
                    complete = false
                    break
                  else
                    complete = true
                  end
                end
                if error
                  raise Exception.new(error_msg)
                end
                return complete
              else
                if status.device_entry['result'] =~ /FAIL/
                  raise Exception.new("Job completed but device commit failed: #{status.device_entry['details']['msg']['errors']['line']}")
                elsif status.device_entry['result'] =~ /PEND/
                  return false
                else
                  return true
                end
              end
            end
          else
            # check the message.  If it's because another commit is already running, return true.
            if !status.device_entry.nil?
              if status.device_entry.is_a? Array
                complete = false
                error = true
                error_msg = ''
                status.device_entry.each do |entry|
                  # check the failed entries
                  if entry['result'] =~ /FAIL/
                    if entry['details']['msg']['errors']['line'] =~ /Another commit/
                      puts('Another commit is in progress.  Let it do the commit, returning true...')
                      error = false
                      complete = true
                    else
                      # must have failed for a different reason
                      error_msg = entry['details']['msg']['errors']['line']
                      error = true
                      complete = false
                    end
                  end
                end
                if error
                  raise Exception.new("Job completed but failed: #{error_msg}")
                end
                return complete
              else
                if status.device_entry['details']['msg']['errors']['line'] =~ /Another commit/
                  puts('Another commit is in progress.  Let it do the commit, returning true...')
                  return true
                else
                  # must have failed for a different reason
                  raise Exception.new("Job completed but failed: #{status.device_entry['details']['msg']['errors']['line']}")
                end
              end
            end
          end
        else
          return false
        end
      end
    end

  end
end
