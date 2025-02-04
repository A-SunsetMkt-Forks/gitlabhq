# frozen_string_literal: true

module FindSnippet
  extend ActiveSupport::Concern
  include Gitlab::Utils::StrongMemoize

  private

  # rubocop:disable CodeReuse/ActiveRecord
  def snippet
    snippet_klass.inc_relations_for_view.find_by(snippet_find_params)
  end
  strong_memoize_attr :snippet
  # rubocop:enable CodeReuse/ActiveRecord

  def snippet_klass
    raise NotImplementedError
  end

  def snippet_id
    params[:id]
  end

  def snippet_find_params
    { id: snippet_id }
  end
end
