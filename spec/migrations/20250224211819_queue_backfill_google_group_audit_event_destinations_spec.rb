# frozen_string_literal: true

require 'spec_helper'
require_migration!

RSpec.describe QueueBackfillGoogleGroupAuditEventDestinations,
  migration: :gitlab_main,
  feature_category: :audit_events do
  let(:batched_migration) { described_class::MIGRATION }

  it 'schedules a new batched migration' do
    reversible_migration do |migration|
      migration.before -> {
        expect(batched_migration).not_to have_scheduled_batched_migration
      }

      migration.after -> {
        expect(batched_migration).to have_scheduled_batched_migration(
          table_name: :audit_events_google_cloud_logging_configurations,
          column_name: :id,
          interval: described_class::DELAY_INTERVAL,
          batch_size: described_class::BATCH_SIZE,
          sub_batch_size: described_class::SUB_BATCH_SIZE,
          gitlab_schema: :gitlab_main
        )
      }
    end
  end

  it 'removes scheduled migration when rolling back' do
    disable_migrations_output do
      migrate!
      schema_migrate_down!
    end

    expect(batched_migration).not_to have_scheduled_batched_migration
  end
end
