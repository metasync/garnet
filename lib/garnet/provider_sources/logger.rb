# frozen_string_literal: true

module Garnet
  module ProviderSources
    module Logger
      class Source < Dry::System::Provider::Source
        setting :name, constructor: Dry.Types::String.constrained(filled: true)

        setting :log_level, default: :info, constructor:
          Dry.Types::Symbol.constructor { |v|
            v.to_s.downcase.to_sym
          }.enum(:trace, :unknown, :error, :fatal, :warn, :info, :debug).constrained(filled: true)

        setting :log_formatter, default: :string, constructor:
          Dry.Types::Symbol.constructor { |v|
            v.to_s.downcase.to_sym
          }.enum(:string, :rack, :json).constrained(filled: true)

        def prepare
          require 'dry/logger'
        end

        def start
          register(
            :logger,
            Dry.Logger(
              config.name,
              level: config.log_level || :info,
              formatter: config.log_formatter || :string,
              template: :details
            )
          )
        end
      end
    end
  end
end

Dry::System.register_provider_source(
  :logger,
  group: :garnet,
  source: Garnet::ProviderSources::Logger::Source
)
