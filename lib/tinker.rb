require "tinker/version"

require 'singleton'
require 'socket'
require 'json'
require 'set'
require 'securerandom'
require 'em-websocket'

require 'pry'

require 'tinker/monkey_patch'

require 'tinker/evented'
require 'tinker/context'
require 'tinker/context/roster'

require 'tinker/reactor'
require 'tinker/engine'
require 'tinker/application'
require 'tinker/room'
require 'tinker/client'
require 'tinker/websocket'
require 'tinker/network/message'

require 'tinker/event'
require 'tinker/event/environment'


module Tinker
  class << self
    attr_accessor :application
  end
end
