# frozen_string_literal: true

# Be sure to restart your server when you modify this file.

# Add new inflection rules using the following format
# (all these examples are active by default):
# ActiveSupport::Inflector.inflections do |inflect|
#   inflect.plural /^(ox)$/i, '\1en'
#   inflect.singular /^(ox)en/i, '\1'
#   inflect.irregular 'person', 'people'
#   inflect.uncountable %w( fish sheep )
# end
#
ActiveSupport::Inflector.inflections do |inflect|
  inflect.uncountable %w[
    custom_emoji
    award_emoji
    ci_secure_file_registry
    container_repository_registry
    dependency_proxy_blob_registry
    design_management_repository_registry
    dependency_proxy_manifest_registry
    duo_enterprise
    duo_pro
    event_log
    file_registry
    group_view
    group_wiki_repository_registry
    job_artifact_registry
    lfs_object_registry
    merge_request_diff_registry
    package_file_registry
    pages_deployment_registry
    pipeline_artifact_registry
    project_auto_devops
    project_registry
    project_wiki_repository_registry
    project_repository_registry
    project_statistics
    snippet_repository_registry
    system_note_metadata
    terraform_state_version_registry
    vulnerabilities_feedback
    vulnerability_feedback
    wiki_page_meta
    WikiPage::Meta
  ]
  inflect.acronym 'CDN'
  inflect.acronym 'EE'
  inflect.acronym 'JH'
  inflect.acronym 'CSP'
  inflect.acronym 'VSCode'
  inflect.acronym 'FIPS'
end
