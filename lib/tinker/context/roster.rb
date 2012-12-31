module Tinker::Context::Roster
  module Synchronize
    def self.included(base)
      raise ArgumentError, 'Must be included in a `Tinker::Context`' unless base < Tinker::Context

      base.send :include, InstanceMethods

      base.on "client.join", :synchronize_roster
      base.on "client.leave", :synchronize_roster
    end

    module InstanceMethods
      def synchronize_roster(event)
        broadcast :action => "meta.roster.synchronize", :params => { :roster => @roster }
      end
    end
  end
end