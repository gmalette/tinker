module Tinker::Evented
  def on(event_name, *callbacks, &block)
    raise ArgumentError, 'No callbacks given' unless callbacks.any? || block
    _dispatchers[event_name].push(*callbacks) if callbacks.any?
    _dispatchers[event_name].push(&block) if block
  end

  # Internal: Disatches an event
  #
  # event - The event to dispatch to the listeners
  #
  # Examples
  #
  #     @room.dispatch(Event.new(:name => "event_name", :params => {:param1 => "value1"}))
  def dispatch(event)
    _dispatchers[event.name].each do |callback|
      event_callback event, callback
    end
  end

  protected 
  def event_callback(event, callback)
    if callback.respond_to? :call
      callback.call(event)
    elsif callback.is_a?(Class) && callback.instance_methods.include?(:call)
      callback.new.call(event)
    elsif callback.is_a?(Symbol) && self.respond_to?(callback)
      self.send(callback, event)
    end
  end

  private
  def _dispatchers
    @dispatchers ||= Hash.new{|h,k| h[k] = []}
  end
end