# frozen_string_literal: true

module Garnet
  module Actor
    class Base
      include Dry::Monads[:result]
      include Garnet::Utils::PrettyPrint

      def initialize(**opts)
        @input_queue = opts[:input_queue] || Queue.new
        @running = true
        @actor = Thread.new { run_action_loop }
      end

      def request(action, **data) = enqueue({ action:, data: })

      def stop(max_wait = nil)
        logger.info "Shutting down #{self.class.name}"
        shutdown
        wait_for_termination(max_wait)
      end

      def shutdown
        @running = false
        request(:no_op)
      end

      def wait_for_termination(max_wait = nil)
        raise WaitError, 'Worker CANNOT wait itself.' if @actor == Thread.current

        if @actor.join(max_wait).nil?
          kill
          logger.info "Forced to shutdown #{self.class.name} after waiting for #{max_wait} seconds"
          false
        else
          logger.info "Completed shutdown of #{self.class.name}"
          true
        end
      end

      def kill = @actor&.kill

      def alive? = @actor&.alive?

      def inspect =
        "#<#{self.class}:0x#{(object_id << 1).to_s(16)} #{alive? ? 'alive' : 'dead'}>"

      protected

      def enqueue(message)
        @input_queue.push(message)
        nil
      end

      def run_action_loop
        run_action while @running
      end

      def run_action
        message = @input_queue.pop
        run_action!(**message).tap do |result|
          if message[:data].key?(:__callback)
            callback = message[:data][:__callback]
            actor_name = message[:data][:__from]
            Garnet.actor(actor_name).request(callback, request: message, result:) unless callback.nil?
          end
        end
      end

      def run_action!(action:, data:)
        raise NoActionError, "Undefined action: #{action}" unless respond_to?(action, include_all: true)

        send(action).call(data)
      rescue StandardError => e
        logger.error pretty_exception(e)
        Failure(e)
      end

      def no_op = proc {}
    end
  end
end
