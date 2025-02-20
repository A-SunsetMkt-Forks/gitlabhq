# frozen_string_literal: true

module ActiveContext
  module CollectionCache
    class << self
      TTL = 1.minute

      def collections
        refresh_cache if cache_expired?

        @collections ||= {}
      end

      def fetch(value)
        by_id(value) || by_name(value)
      end

      def by_id(id)
        collections[id]
      end

      def by_name(name)
        collections.values.find { |collection| collection.name == name.to_s }
      end

      private

      def cache_expired?
        return true unless @last_refreshed_at

        Time.current - @last_refreshed_at > TTL
      end

      def refresh_cache
        new_collections = {}

        Config.collection_model.find_each do |record|
          new_collections[record.id] = record
        end

        @collections = new_collections
        @last_refreshed_at = Time.current
      end
    end
  end
end
