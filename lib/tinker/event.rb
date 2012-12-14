class Tinker::Event
  attr_accessor :environment, :params, :name

  def initialize( attributes = {} )
    [:environment, :params, :name].each do |attribute|
      instance_variable_set("@#{attribute}", attributes[attribute])
    end
  end

  def env
    environment
  end
end