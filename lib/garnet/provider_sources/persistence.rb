# frozen_string_literal: true

module Garnet
  module ProviderSources
    module Persistence
      class Source < Dry::System::Provider::Source
        setting :name, constructor: Dry.Types::String.optional
        setting :db_user, constructor: Dry.Types::String.constrained(filled: true)
        setting :db_password, constructor: Dry.Types::String.optional
        setting :db_password_encrypted, constructor: Dry.Types::String.optional
        setting :database_url, constructor: Dry.Types::String.constrained(filled: true)
        setting :enable_sql_log, default: false, constructor: Dry.Types::Params::Bool.optional

        def named? = !config.name.nil?
        def name_prefix = named? ? "persistence.#{config.name}." : 'persistence.'

        def namespace_suffix
          named? ? "::#{target.config.inflector.classify(config.name)}" : ''
        end

        def sql_log_enabled? = config.enable_sql_log

        def prepare
          require 'rom'

          create_rom_config.tap do |cfg|
            cfg.gateways[:default].use_logger(target[:logger]) if sql_log_enabled?
            register "#{name_prefix}config", cfg
            register "#{name_prefix}db", cfg.gateways[:default].connection
          end
        end

        def start
          rom_config = target["#{name_prefix}config"]
          auto_load_persistence(rom_config)
          register "#{name_prefix}rom", ROM.container(rom_config)
        end

        def db_password
          if config.db_password_encrypted.nil? ||
             config.db_password_encrypted.empty?
            config.db_password
          else
            db_password_decrypted
          end
        end

        def db_password_decrypted
          Utils::Cipher.new.decrypt(config.db_password_encrypted)
        end

        protected

        def create_rom_config
          ROM::Configuration.new(
            :sql, config.database_url,
            username: config.db_user,
            password: db_password,
            migrator: { path: Pathname('db/migrate').join(config.name.to_s) }
          )
        end

        def auto_load_persistence(rom_config)
          rom_config.auto_registration(
            target.root.join('lib/app/persistence').join(config.name.to_s),
            namespace: "#{target.root_namespace}::Persistence#{namespace_suffix}"
          )
        end
      end
    end
  end
end

Dry::System.register_provider_source(
  :persistence,
  group: :garnet,
  source: Garnet::ProviderSources::Persistence::Source
)
