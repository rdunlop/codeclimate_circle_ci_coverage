Gem::Specification.new do |s|
  s.name        = 'codeclimate_circle_ci_coverage'
  s.version     = '0.0.1'
  s.date        = '2016-03-08'
  s.summary     = 'CodeClimate Code Coverage reporting script for CircleCI'
  s.description = 'A set of tools to support reporting SimpleCov Coverage to CodeClimate with Parallel tests on CircleCI'
  s.authors     = ['Robin Dunlop']
  s.email       = 'robin@dunlopweb.com'
  s.homepage    = 'https://github.com/rdunlop/codeclimate_circle_ci_coverage'
  s.files       = [
    'lib/codeclimate_circle_ci_coverage.rb',
    'lib/codeclimate_circle_ci_coverage/circle.rb',
  ]
  s.executables << 'report_coverage'
  s.homepage =
    'http://rubygems.org/gems/codeclimate_circle_ci_coverage'
  s.license = 'MIT'
  s.add_runtime_dependency 'codeclimate-test-reporter'
  s.add_runtime_dependency 'simplecov'

  s.add_development_dependency 'rubocop'
end
