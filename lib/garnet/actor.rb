# frozen_string_literal: true

module Garnet
  class Actor
    include Dry::Monads[:result]
    include Garnet::Utils::PrettyPrint

    def initialize
      @input_queue = Queue.new
      @running = true
      @actor = Thread.new { run_action_loop }
    end

    def request(action, **data)
      enqueue({ action:, data: })
    end

    def stop
      enqueue({ action: :shutdown })
    end

    def kill = @actor.kill

    def join(max_wait = nil)
      raise JoinError, 'Worker CANNOT join itself.' if @actor == Thread.current
      return true unless @actor.join(max_wait).nil?

      kill and return false
    end

    def dispose(max_wait = nil)
      stop
      join(max_wait)
    end

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
      logger.info "Completed shutdown of #{self.class.name}"
    end

    def run_action
      message = @input_queue.pop
      action = message[:action]
      raise NoActionError, "Undefined action: #{action}" unless respond_to?(action, include_all: true)

      message[:result] = run_action!(action, message[:data])
    rescue StandardError => e
      logger.error pretty_exception(e)
      Failure(e)
    end

    def run_action!(action, data)
      if action == :shutdown
        shutdown
      else
        send(action).call(data)
      end
    end

    def shutdown
      @running = false
    end
  end
end
