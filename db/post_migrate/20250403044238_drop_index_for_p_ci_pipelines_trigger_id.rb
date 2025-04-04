# frozen_string_literal: true

class DropIndexForPCiPipelinesTriggerId < Gitlab::Database::Migration[2.2]
  include Gitlab::Database::PartitioningMigrationHelpers
  include Gitlab::Database::MigrationHelpers::WraparoundAutovacuum

  milestone '17.11'
  disable_ddl_transaction!

  TABLE_NAME = :p_ci_pipelines
  COLUMN_NAMES = [:trigger_id]
  INDEX_NAME = :p_ci_pipelines_trigger_id_idx

  def up
    return unless can_execute_on?(:ci_pipelines)

    remove_concurrent_partitioned_index_by_name(TABLE_NAME, INDEX_NAME)
  end

  def down
    return unless can_execute_on?(:ci_pipelines)

    add_concurrent_partitioned_index(TABLE_NAME, COLUMN_NAMES, name: INDEX_NAME)
  end
end
