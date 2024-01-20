# frozen_string_literal: true

require 'rom/sql/rake_task'

namespace :db do
  task :setup do
    require Garnet.app.root.join('system/providers/persistence')

    provider_name = (ENV['PERSISTENCE_PROVIDER'] || 'persistence').to_sym
    Garnet.prepare(provider_name)

    provider = Garnet.app.providers[provider_name]
    ROM::SQL::RakeSupport.env = Garnet.app[
      provider.source.named? ? "persistence.#{provider.source.config.name}.config" : 'persistence.config'
    ]
  end
end
