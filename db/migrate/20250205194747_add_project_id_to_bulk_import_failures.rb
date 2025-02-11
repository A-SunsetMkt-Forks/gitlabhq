# frozen_string_literal: true

class AddProjectIdToBulkImportFailures < Gitlab::Database::Migration[2.2]
  milestone '17.9'

  def change
    add_column :bulk_import_failures, :project_id, :bigint
  end
end
