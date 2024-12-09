# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Projects::BranchRules::SquashOption, feature_category: :source_code_management do
  it_behaves_like 'projects squash option'
end
