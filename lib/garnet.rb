# frozen_string_literal: true

require 'dry/system'
require 'dry/types'

require_relative 'garnet/version'
require_relative 'garnet/utils'
require_relative 'garnet/contract'
require_relative 'garnet/message'
require_relative 'garnet/container'
require_relative 'garnet/action'
require_relative 'garnet/actor'
require_relative 'garnet/errors'
require_relative 'garnet/provider_sources'

module Garnet
  Types = Dry.Types
  @_mutex = Mutex.new
  @_services = {}

  def self.app
    @_mutex.synchronize do
      raise AppLoadError, 'Garnet.app is not yet configured. ' unless defined?(@_app)

      @_app
    end
  end

  def self.app? = instance_variable_defined?(:@_app)

  def self.app=(klass)
    @_mutex.synchronize do
      raise AppLoadError, 'Garnet.app is already configured.' if app?

      @_app = klass unless klass.name.nil?
    end
  end

  def self.services = @_services

  def self.services? = !@_services.empty?

  def self.register_service(klass)
    @_mutex.synchronize do
      @_services[klass.service_name] = klass
    end
  end

  def self.service(service_name)
    @_services[service_name]
  end

  def self.actor(name)
    service_name, actor_name = name.split('.', 2)
    @_services[service_name][actor_name]
  end

  def self.setup
    ENV['GARNET_ENV'] ||= 'development'

    require 'bundler'
    Bundler.setup(:default, ENV['GARNET_ENV'])
  end

  def self.prepare(...)
    setup
    app.prepare(...)
  end

  def self.boot
    setup
    app.finalize!
    @_services.each_value(&:finalize!)
    @_services.freeze
  end
end
