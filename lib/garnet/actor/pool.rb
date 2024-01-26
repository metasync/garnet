# frozen_string_literal: true

module Garnet
  module Actor
    class Pool
      def initialize
        @input_queue = Queue.new
        @actors = Set.new
        create_actors
      end

      def actor_class
        raise NotImplementedError, "#{name}##{__method__} is an abstract method."
      end

      def size
        raise NotImplementedError, "#{name}##{__method__} is an abstract method."
      end

      def request(action, **data) = enqueue({ action:, data: })

      def stop(max_wait = nil)
        shutdown
        logger.info "Completed shutdown of #{self.class.name}" if wait_for_termination(max_wait).all?
      end

      def shutdown = @actors.each(&:shutdown)

      def wait_for_termination(max_wait = nil)
        results = @actors.map { |a| a.wait_for_termination(max_wait) }
        @actors.clear
        results
      end

      def inspect
        "#<#{self.class}:0x#{(object_id << 1).to_s(16)} size=#{size}>"
      end

      protected

      def create_actors
        size.times do
          @actors << actor_class.new(input_queue: @input_queue)
        end
      end

      def enqueue(message)
        @input_queue.push(message)
        nil
      end
    end
  end
end
