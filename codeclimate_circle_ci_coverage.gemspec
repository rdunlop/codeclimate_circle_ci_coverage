# frozen_string_literal: true

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'codeclimate_circle_ci_coverage/version'

Gem::Specification.new do |s|
  s.name        = 'codeclimate_circle_ci_coverage'
  s.version     = CodeclimateCircleCiCoverage::VERSION
  s.summary     = 'CodeClimate Code Coverage reporting script for CircleCI'
  s.description = 'A set of tools to support reporting SimpleCov Coverage to CodeClimate with Parallel tests on CircleCI'
  s.authors     = ['Robin Dunlop']
  s.email       = 'robin@dunlopweb.com'
  s.homepage    = 'https://github.com/rdunlop/codeclimate_circle_ci_coverage'
  s.license     = "MIT"
  s.files       = [
    'lib/codeclimate_circle_ci_coverage.rb',
    'lib/codeclimate_circle_ci_coverage/coverage_reporter.rb',
    'lib/codeclimate_circle_ci_coverage/patch_simplecov.rb',
    'lib/codeclimate_circle_ci_coverage/circle_ci_1.rb',
    'lib/codeclimate_circle_ci_coverage/circle_ci_2.rb',
    'lib/codeclimate_circle_ci_coverage/version.rb',
  ]
  s.test_files = [
    'spec/coverage_reporter_spec.rb',
    'spec/spec_helper.rb',
  ]
  s.executables << 'report_coverage'
  s.add_runtime_dependency 'codeclimate-test-reporter', '>= 1.0', '< 2'
  s.add_runtime_dependency 'simplecov', '~> 0.11'

  s.add_development_dependency "bundler", "~> 1.11"
  s.add_development_dependency "rake", "~> 10.0"
  s.add_development_dependency 'rspec', '~> 3.4'
  s.add_development_dependency 'rubocop'
end
