module Panos
  class Job

    attr_reader :id

    def initialize(id)
      fail ArgumentError, 'id cannot be nil' if id.nil?
      fail ArgumentError, 'id must be an Integer' if !id.is_a?(Integer)

      super()
      @id = id
    end

  end
end