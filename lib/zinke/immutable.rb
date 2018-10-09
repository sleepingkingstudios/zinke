# frozen_string_literal: true

require 'hamster'

require 'zinke'

module Zinke
  # Utility methods for converting to and from immutable objects.
  module Immutable
    IMMUTABLE_DATA_STRUCTURES = [
      Hamster::Hash,
      Hamster::List,
      Hamster::Set,
      Hamster::SortedSet,
      Hamster::Vector
    ].freeze

    def self.dig(immutable, *keys)
      unless IMMUTABLE_DATA_STRUCTURES.any? { |klass| immutable.is_a?(klass) }
        raise ArgumentError, 'argument must be an immutable data structure'
      end

      dig_object(immutable, keys)
    end

    class << self
      private

      def dig_keyed(hsh, key, *rest)
        obj = hsh[key]

        rest.empty? ? obj : dig_object(obj, rest)
      end

      def dig_indexed(vec, key, *rest)
        obj = vec[key]

        rest.empty? ? obj : dig_object(obj, rest)
      end

      # rubocop:disable Metrics/MethodLength
      def dig_object(obj, keys)
        case obj
        when nil
          nil
        when Hamster::Hash
          dig_keyed(obj, *keys)
        when Hamster::List, Hamster::SortedSet, Hamster::Vector
          dig_indexed(obj, *keys)
        when ->(_) { obj.respond_to?(:dig) }
          # :nocov:
          obj.dig(*keys)
          # :nocov:
        else
          raise TypeError, "#{obj.class} does not have #dig method"
        end
      end
      # rubocop:enable Metrics/MethodLength
    end
  end
end
