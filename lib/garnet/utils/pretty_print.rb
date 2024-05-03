# frozen_string_literal: true

require 'pp'

module Garnet
  module Utils
    module PrettyPrint
      def pretty_backtrace(exception)
        "\tat #{exception.backtrace.join("\n\tat ")}"
      end

      def pretty_exception(exception)
        "#{exception.message}\n#{pretty_backtrace(exception)}"
      end

      def pretty_inspect(obj)
        "\t#{obj.pretty_inspect.split("\n").join("\n\t")}"
      end
    end
  end
end
