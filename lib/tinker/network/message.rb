module Tinker::Network
  class Message
    attr_reader :socket, :body

    def initialize(params)
      [:socket, :body].each do |param|
        instance_variable_set("@#{param}", params[param])
      end
    end
  end
end