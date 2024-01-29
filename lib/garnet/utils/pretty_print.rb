# frozen_string_literal: true

require 'pp'

module Garnet
  module Utils
    module PrettyPrint
      def pretty_backtrace(exception) =
        "\tat #{exception.backtrace.join("\n\tat ")}"

      def pretty_exception(exception) =
        "#{exception.message}\n#{pretty_backtrace(exception)}"

      def pretty_inspect(obj) =
        "\t#{obj.pretty_inspect.split("\n").join("\n\t")}"
    end
  end
end
