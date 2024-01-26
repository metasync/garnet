# frozen_string_literal: true

require 'dry/monads'
require 'ulid'

module Garnet
  class Message
    include Dry::Monads[:result]
    include Garnet::Utils::PrettyPrint

    class << self
      def from(sender)
        define_method(:from) { sender.to_sym }
        define_method(:sender) { @sender ||= Garnet.actor(sender) }
      end

      def to(receiver)
        define_method(:to) { receiver.to_sym }
        define_method(:receiver) { @receiver ||= Garnet.actor(receiver) }
      end

      def action(action_name)
        define_method(:action) { action_name.to_sym }
      end
    end

    def contract_defined? = self.class.method_defined?(:contract)

    def deliver!(data)
      deliver(data).or do |r|
        raise InvalidContract, "Invalid contract for #{self.class.name}: \n#{pretty_inspect(r.errors.to_h)}"
      end
    end

    def deliver(data)
      validate_contract(data).fmap do |d|
        Success(deliver_message(d.to_h))
      end
    end

    protected

    def validate_contract(data) =
      if contract_defined?
        contract.call(data).to_monad
      else
        Success(data)
      end

    def deliver_message(data)
      data.merge(
        __from: from,
        __message_id: ULID.generate,
        __delivered_at: Time.now
      ).tap do |message|
        receiver.request(action, **message)
      end
    end
  end
end
