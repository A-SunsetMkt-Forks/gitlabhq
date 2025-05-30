# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Ci::CreatePipelineService,
  feature_category: :continuous_integration do
  context 'cache' do
    let(:project)  { create(:project, :custom_repo, files: files) }
    let(:user)     { project.first_owner }
    let(:ref)      { 'refs/heads/master' }
    let(:source)   { :push }
    let(:service)  { described_class.new(project, user, { ref: ref }) }
    let(:pipeline) { service.execute(source).payload }
    let(:job)      { pipeline.builds.find_by(name: 'job') }

    before do
      stub_ci_pipeline_yaml_file(config)
    end

    context 'with cache:key' do
      let(:files) { { 'some-file' => '' } }

      let(:config) do
        <<~EOY
        job:
          script:
            - ls
          cache:
            key: 'a-key'
            paths: ['logs/', 'binaries/']
            untracked: true
        EOY
      end

      it 'uses the provided key' do
        expected = {
          key: a_string_matching(/^a-key-(?>protected|non_protected)$/),
          paths: ['logs/', 'binaries/'],
          policy: 'pull-push',
          untracked: true,
          unprotect: false,
          when: 'on_success',
          fallback_keys: []
        }

        expect(pipeline).to be_persisted
        expect(job.cache).to match(a_collection_including(expected))
      end
    end

    context 'with cache:key:files' do
      let(:config) do
        <<~EOY
        job:
          script:
            - ls
          cache:
            paths:
              - logs/
            key:
              files:
                - file.lock
                - missing-file.lock
        EOY
      end

      context 'when file.lock exists' do
        let(:files) { { 'file.lock' => '' } }

        it 'builds a cache key' do
          expected = {
            key: /[a-f0-9]{40}/,
            paths: ['logs/'],
            policy: 'pull-push',
            when: 'on_success',
            unprotect: false,
            fallback_keys: []
          }

          expect(pipeline).to be_persisted
          expect(job.cache).to match(a_collection_including(expected))
        end
      end

      context 'when file.lock does not exist' do
        let(:files) { { 'some-file' => '' } }

        it 'uses default cache key' do
          expected = {
            key: /default/,
            paths: ['logs/'],
            policy: 'pull-push',
            when: 'on_success',
            unprotect: false,
            fallback_keys: []
          }

          expect(pipeline).to be_persisted
          expect(job.cache).to match(a_collection_including(expected))
        end
      end
    end

    context 'with cache:key:files and prefix' do
      let(:config) do
        <<~EOY
        job:
          script:
            - ls
          cache:
            paths:
              - logs/
            key:
              files:
                - file.lock
              prefix: '$ENV_VAR'
        EOY
      end

      context 'when file.lock exists' do
        let(:files) { { 'file.lock' => '' } }

        it 'builds a cache key' do
          expected = {
            key: /\$ENV_VAR-[a-f0-9]{40}/,
            paths: ['logs/'],
            policy: 'pull-push',
            when: 'on_success',
            unprotect: false,
            fallback_keys: []
          }

          expect(pipeline).to be_persisted
          expect(job.cache).to match(a_collection_including(expected))
        end
      end

      context 'when file.lock does not exist' do
        let(:files) { { 'some-file' => '' } }

        it 'uses default cache key' do
          expected = {
            key: /\$ENV_VAR-default/,
            paths: ['logs/'],
            policy: 'pull-push',
            when: 'on_success',
            unprotect: false,
            fallback_keys: []
          }

          expect(pipeline).to be_persisted
          expect(job.cache).to match(a_collection_including(expected))
        end
      end
    end

    context 'with too many files' do
      let(:files) { { 'some-file' => '' } }

      let(:config) do
        <<~EOY
        job:
          script:
            - ls
          cache:
            paths: ['logs/', 'binaries/']
            untracked: true
            key:
              files:
                - file.lock
                - other-file.lock
                - extra-file.lock
              prefix: 'some-prefix'
        EOY
      end

      it 'has errors' do
        expect(pipeline).to be_persisted
        expect(pipeline.error_messages[0].content).to eq(
          "jobs:job:cache:key:files config has too many items (maximum is 2)")
        expect(job).to be_nil
      end
    end
  end
end
