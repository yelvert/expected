# frozen_string_literal: true

PROJECT_ROOT = File.expand_path('..', __dir__)
$LOAD_PATH << File.join(PROJECT_ROOT, 'lib')

require 'pry'
require 'pry-doc'
require 'pry-nav'
require 'pry-remote'

require 'faker'
require 'rspec'
require 'simplecov_helper'

require 'active_support/all'

require 'expected'

Dir[File.join(File.expand_path('support/**/*.rb', __dir__))].sort.each do |file|
  require file
end

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.include Expected::Matchers

  config.order = :random
  config.default_formatter = 'doc'
  config.mock_with :rspec
  config.example_status_persistence_file_path = 'coverage/rspec.txt'
end

Expected.configure do |config|
end

$VERBOSE = true
