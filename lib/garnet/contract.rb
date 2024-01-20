# frozen_string_literal: true

require 'dry/validation'

Dry::Validation.load_extensions(:monads)

module Garnet
  class Contract < Dry::Validation::Contract
  end
end
