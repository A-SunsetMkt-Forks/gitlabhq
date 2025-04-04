# frozen_string_literal: true

class AddPackagesPackageFileBuildInfosProjectIdFk < Gitlab::Database::Migration[2.2]
  milestone '17.11'
  disable_ddl_transaction!

  def up
    add_concurrent_foreign_key :packages_package_file_build_infos, :projects, column: :project_id, on_delete: :cascade
  end

  def down
    with_lock_retries do
      remove_foreign_key :packages_package_file_build_infos, column: :project_id
    end
  end
end
