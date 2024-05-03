# frozen_string_literal: true

module Garnet
  class Application < Container
    class << self
      attr_reader :app_name

      def inherited(subclass)
        super
        setup_env(subclass)
        setup_container_name(subclass, :@app_name)
        setup_types(subclass)
        setup_deps(subclass)
        setup_autoload(subclass)
        setup_component_dirs(subclass)
        setup_inflector(subclass)
        Garnet.app = subclass
      end

      # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      def setup_component_dirs(subclass)
        subclass.configure do |config|
          config.component_dirs.add 'app' do |dir|
            dir.namespaces.add_root const: container_name(subclass)
            dir.memoize = proc do |component|
              component.identifier.start_with?('actors')
            end
          end
          config.component_dirs.add 'lib/app' do |dir|
            dir.auto_register = false
            dir.namespaces.add_root const: container_name(subclass)
            dir.memoize = true
          end
        end
      end
      # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

      def setup_inflector(klass)
        klass.register('inflector', config.inflector)
      end
    end
  end
end
