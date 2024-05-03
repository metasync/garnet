# frozen_string_literal: true

module Garnet
  module Actor
    class Pool
      class << self
        def actor_class(klass)
          define_method(:actor_class) { klass }
        end

        def size(pool_size = 0, &)
          if block_given?
            define_method(:size, &)
          else
            define_method(:size) { pool_size }
          end
        end
      end

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
        logger.info "Shutting down #{self.class.name}"
        shutdown
        wait_for_termination(max_wait)
      end

      def shutdown = @actors.each(&:shutdown)

      def wait_for_termination(max_wait = nil)
        results = @actors.map { |a| a.wait_for_termination(max_wait) }
        if results.all?
          logger.info "Completed shutdown of #{self.class.name}"
        else
          logger.info "Forced to shutdown #{self.class.name}"
        end
        @actors.clear
        results
      end

      def inspect
        "#<#{self.class}:0x#{(object_id << 1).to_s(16)} size=#{size}>"
      end

      protected

      def create_actors
        size.times { @actors << actor_class.new(**actor_options) }
      end

      def actor_options
        { input_queue: @input_queue }
      end

      def enqueue(message)
        @input_queue.push(message)
        nil
      end
    end
  end
end
