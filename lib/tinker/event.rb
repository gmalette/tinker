class Tinker::Event
  attr_accessor :client, :params, :name

  def initialize( attributes = {} )
    [:client, :params, :name].each do |attribute|
      instance_variable_set("@#{attribute}", attributes[attribute])
    end
  end
end