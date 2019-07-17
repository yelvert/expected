# frozen_string_literal: true

RSpec.configure do |config|
  running = config.instance_variable_get(:@files_or_directories_to_run)
  break unless running.one? && running[0] == config.default_path

  require 'simplecov'

  SimpleCov.start 'rails' do
    require 'rspec/simplecov'

    minimum_coverage 100

    add_filter '/lib/expected/version'

    formatter SimpleCov::Formatter::MultiFormatter.new [
      SimpleCov::Formatter::HTMLFormatter,
    ]
  end

  RSpec::SimpleCov.start
end
