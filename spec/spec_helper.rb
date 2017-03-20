$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'simplecov'
SimpleCov.start

require 'portable_bridge_notation'
require 'logger'
require 'lib/portable_bridge_notation/internals/game_parser_states/game_parser_state_spec_helper'
RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups

  config.filter_run focus: true
  config.run_all_when_everything_filtered = true
  # config.order = :random
  config.alias_it_should_behave_like_to :it_has_behaviour, 'has behavior'
  config.include(PortableBridgeNotation::Internals::GameParserStates::GameParserStateSpecHelper,
                 group: :game_parser_states)
end
