# frozen_string_literal: true

module Garnet
  class Container < Dry::System::Container
    include Utils::Namespace

    class << self
      protected

      def setup_env(klass)
        klass.use :env, inferrer: -> { ENV.fetch('GARNET_ENV', :development).to_sym }
      end

      def setup_autoload(klass)
        klass.use :zeitwerk
        # klass.use :zeitwerk, eager_load: true
        # klass.use :zeitwerk, debug: true
      end

      def setup_monitoring(klass)
        klass.use :monitoring
      end

      def container_name(klass)
        config.inflector.underscore(klass.root_namespace)
      end

      def setup_container_name(klass, var)
        klass.instance_variable_set(var, container_name(klass))
      end

      def setup_types(klass)
        klass.root_namespace.const_set('Types', Dry.Types)
      end

      def setup_deps(klass)
        klass.root_namespace.const_set('Deps', klass.injector)
      end
    end
  end
end