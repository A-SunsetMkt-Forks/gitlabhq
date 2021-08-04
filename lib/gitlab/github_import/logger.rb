# frozen_string_literal: true

module Gitlab
  module GithubImport
    class Logger < ::Gitlab::Import::Logger
      def default_attributes
        super.merge(import_source: :github)
      end
    end
  end
end
