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
      # enqueue(req.merge(action: action))
    end

    def stop = enqueue({ action: :shutdown })

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
      shutdown
    end

    def run_action
      message = @input_queue.pop
      raise NoActionError, "The given action is NOT defined:  #{message[:action]}" unless respond_to?(message[:action])

      message[:result] = send(message[:action]).call(message[:data])
    rescue StandardError => e
      logger.error pretty_exception(e)
      Failure(e)
    end

    def shutdown(*_args)
      @running = false
    end
  end
end
