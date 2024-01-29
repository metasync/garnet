# frozen_string_literal: true

module Garnet
  class Service < Container
    class << self
      attr_reader :service_name

      def inherited(subclass)
        super
        setup_env(subclass)
        setup_container_name(subclass, :@service_name)
        # setup_types(subclass)
        setup_deps(subclass)
        setup_autoload(subclass)
        setup_component_dirs(subclass)
        Garnet.register_service(subclass)
      end

      def setup_component_dirs(subclass)
        subclass.configure do |config|
          config.root = 'services'
          config.component_dirs.add subclass.service_name do |dir|
            dir.namespaces.add_root const: subclass.service_name
            dir.memoize = proc do |component|
              component.identifier.start_with?('actors')
            end
          end
        end
      end
    end
  end
end
