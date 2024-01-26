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
        shutdown
        wait_for_termination(max_wait)
      end

      def shutdown
        @running = false
      end

      def wait_for_termination(max_wait = nil)
        raise WaitError, 'Worker CANNOT wait itself.' if @actor == Thread.current

        if @actor.join(max_wait).nil?
          kill
          false
        else
          logger.info "Completed shutdown of #{self.class.name}"
          true
        end
      end

      def kill = @actor.kill

      def alive?
        @actor&.alive?
      end

      def inspect
        "#<#{self.class}:0x#{(object_id << 1).to_s(16)} #{alive? ? 'alive' : 'dead'}>"
      end

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
        action = message[:action]
        raise NoActionError, "Undefined action: #{action}" unless respond_to?(action, include_all: true)

        message[:result] = send(action).call(message[:data])
      rescue StandardError => e
        logger.error pretty_exception(e)
        Failure(e)
      end
    end
  end
end
