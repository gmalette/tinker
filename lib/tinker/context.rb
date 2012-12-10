module Tinker::Context
  
  def on event_name, *callbacks, &block = nil
    raise ArgumentError, 'No callbacks given' unless callbacks.any? || block_given?
  end

  def dispatch event

  end
end