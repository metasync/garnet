# frozen_string_literal: true

module Garnet
  module Actor
    class Sync < Base
      def initialize(**opts)
        super
        @pending_requests = opts[:pending_requests] || Concurrent::Map.new
      end

      def yield(data = nil)
        @pending_requests[Fiber.current.object_id] = Fiber.current
        Fiber.yield data
      end

      protected

      def run_action
        Fiber.new { super }.resume
      end
    end
  end
end
