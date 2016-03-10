# CodeClimate CircleCI Coverage

[![Code Climate](https://codeclimate.com/github/rdunlop/codeclimate_circle_ci_coverage.png)](https://codeclimate.com/github/rdunlop/codeclimate_circle_ci_coverage)

[CircleCI](https://circleci.com) provides a great CI environment, and allows your test suite to be run in multiple containers in parallel.

[CodeClimate](https://codeclimate.com) provides great metrics about the health of your codebase.

Unfortunately, CodeClimate [only supports a single payload of coverage data](https://docs.codeclimate.com/docs/setting-up-test-coverage#important-fyis) and thus cannot be integrated with CircleCI parallel-test execution without some additional work.

This gem is that additional work.

## Installation

Add this line to your application's Gemfile:

```bash
gem 'codeclimate_circle_ci_coverage'
```

And then add the following to your circle.yml:

```yml
test:
  post:
    - bundle exec report_coverage
```

Add add the following to the top of your spec_helper.rb:
```ruby
require 'simplecov'

# run coverage when on CI
if ENV['CI']
  SimpleCov.start 'rails' do
    add_filter '/spec/'
  end
end

```

## CircleCI Configuration

In order for CircleCI to send coverage information to CodeClimate, it must have your CodeClimate access token.

In CircleCI, add the `CODECLIMATE_REPO_TOKEN` to your Environment Variables.

You can find your `CODECLIMATE_REPO_TOKEN` when logged into CodeClimate:
-> "Settings" -> "Test Coverage" -> "Ruby"

## Usage

CircleCI will now aggregate together all of your individual coverage metrics into a single file, and then upload that file to CodeClimate.

Once your test suite has been run on your default branch, there will be a "Test Coverage" link appear in your CodeClimate feed, as well as on the Sidebar.

**Note** CodeClimate will **only** report coverage metrics on the default branch. Thus, running this on a feature branch will not cause coverage numbers to be reported.


## Known Issues

Currently, running the same build multiple times causes the CodeCoverage numbers to fluctuate a slight amount. I haven't yet figured out whether this a result of the reporting scripts, or my test suite itself.

## Similar Projects

- https://github.com/grosser/codeclimate_batch - TravisCI Integration
- https://github.com/crazydog115/simplecov-s3 - Combines Coverage reports using AWS S3 storage
- https://github.com/mikz/codeclimate-parallel-test-reporter

## Credits

CodeClimate CircelCI Coverage was written by (Robin Dunlop)[https://github.com/rdunlop), based extensively on:

- https://github.com/codeclimate/ruby-test-reporter/issues/10
- https://gist.github.com/evanwhalen/f74879e0549b67eb17bb

