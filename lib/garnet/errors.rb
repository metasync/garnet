# frozen_string_literal: true

module Garnet
  class Error < StandardError; end

  # App Errors
  class AppLoadError < Error; end

  # Actor Errors
  class Actor
    class JoinError < Error; end
    class NoActionError; end
  end

  # Message Errors
  class Message
    class InvalidContract < Error; end
  end
end
