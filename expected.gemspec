# frozen_string_literal: true

$LOAD_PATH << File.join(File.dirname(__FILE__), 'lib')
require 'expected/version'

Gem::Specification.new do |s|
  s.name        = 'expected'
  s.version     = Expected::VERSION.dup
  s.authors     = ['Taylor Yelverton']
  s.date        = Time.now.strftime('%Y-%m-%d')
  s.email       = 'rubygems@yelvert.io'
  s.homepage    = 'https://github.com/yelvert/expected'
  s.summary     = "RSpec's missing matchers"
  s.license     = 'MIT'
  s.description = "RSpec's missing matchers"
  s.metadata    = {
    'bug_tracker_uri' => 'https://github.com/yelvert/expected/issues',
    'changelog_uri' => 'https://github.com/yelvert/expected/commits/master',
    'documentation_uri' => 'https://github.com/yelvert/expected/wiki',
    'homepage_uri' => 'https://github.com/yelvert/expected',
    'source_code_uri' => 'https://github.com/yelvert/expected',
  }

  s.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z -- {docs,lib,README.md,MIT-LICENSE,shoulda-matchers.gemspec}`.
      split("\x0")
  end

  s.require_paths = %w[ lib ]

  s.required_ruby_version = '>= 2.4.0'
  s.add_dependency('activesupport', '~> 5.0', '>= 5.0.0')
end
