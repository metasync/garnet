# frozen_string_literal: true

module Garnet
  module Utils
    module Namespace
      class << self
        def included(base)
          base.extend ClassMethods
        end
      end

      module ClassMethods
        def namespace
          if defined?(@namespace)
            @namespace
          else
            @namespace = name =~ /::[^:]+\Z/ ? Object.const_get(::Regexp.last_match.pre_match, false) : nil
          end
        end

        def root_namespace
          namespace ? Object.const_get(namespace.name.split('::').first, false) : Object
        end
      end
    end
  end
end
