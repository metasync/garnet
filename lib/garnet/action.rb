# frozen_string_literal: true

require 'dry/monads'

module Garnet
  class Action
    include Dry::Monads[:result]
    include Garnet::Utils::PrettyPrint

    def self.handled_exceptions = @handled_exceptions ||= {}

    def self.handle_exception(exception_handlers)
      exception_handlers.each_pair do |exception_class, handler|
        unless respond_to?(handler, include_all: true)
          raise NotImplementedError, "Exception handler #{handler} is NOT defined for exception #{exception_class}."
        end

        @handled_exceptions[m[exception_class]] = handler
      end
    end

    def contract_defined? = self.class.method_defined?(:contract)

    def call(params)
      validate_contract(params).fmap do |p|
        Success(handle(p.to_h))
      end
    rescue StandardError => e
      handle_exception(e)
    end

    protected

    def validate_contract(params)
      = if contract_defined?
          contract.call(params).to_monad
        else
          Success(params)
        end

    def handle(params)
      raise NotImplementedError, "#{self.class.name}##{__method__} is an abstract method."
    end

    def handle_exception(exception)
      if self.class.handled_exceptions.key?(exception)
        method(self.class.handled_exceptions[exception]).call(exception)
      else
        logger.error pretty_exception(exception)
        Failure(exception)
      end
    end
  end
end
