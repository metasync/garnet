# frozen_string_literal: true

require 'pathname'

# Reigster provider source, :settings, in dry/system
require 'dry/system/provider_sources/settings'

# Register provider sources in Garnet
Dry::System.register_provider_sources Pathname(__dir__).join('provider_sources').realpath
