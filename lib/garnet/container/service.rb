# frozen_string_literal: true

module Garnet
  class Service < Container
    def self.inherited(subclass)
      super
      setup_env(subclass)
      setup_container_name(subclass, :@service_name)
      # setup_types(subclass)
      setup_deps(subclass)
      setup_autoload(subclass)
      setup_component_dirs(subclass)
      Garnet.register_service(subclass)
    end

    class << self
      attr_reader :service_name
    end

    def self.setup_component_dirs(subclass)
      subclass.configure do |config|
        config.root = 'services'
        config.component_dirs.add subclass.service_name do |dir|
          dir.namespaces.add_root const: subclass.service_name
        end
      end
    end
  end
end
