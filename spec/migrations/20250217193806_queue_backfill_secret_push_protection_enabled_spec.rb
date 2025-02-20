# frozen_string_literal: true

require 'spec_helper'
require_migration!

RSpec.describe QueueBackfillSecretPushProtectionEnabled, feature_category: :secret_detection do
  let!(:batched_migration) { described_class::MIGRATION }

  it 'schedules a new batched migration' do
    reversible_migration do |migration|
      migration.before -> {
        expect(batched_migration).not_to have_scheduled_batched_migration
      }

      migration.after -> {
        expect(batched_migration).to have_scheduled_batched_migration(
          table_name: :project_security_settings,
          column_name: :project_id,
          interval: described_class::DELAY_INTERVAL,
          batch_size: described_class::BATCH_SIZE,
          sub_batch_size: described_class::SUB_BATCH_SIZE,
          max_batch_size: described_class::MAX_BATCH_SIZE,
          job_arguments: []
        )
      }
    end
  end
end
