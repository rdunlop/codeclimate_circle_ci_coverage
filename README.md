# CodeClimate CircleCI Coverage

[![Code Climate](https://codeclimate.com/github/rdunlop/codeclimate_circle_ci_coverage.png)](https://codeclimate.com/github/rdunlop/codeclimate_circle_ci_coverage)

[CircleCI](https://circleci.com) provides a great CI environment, and allows your test suite to be run in multiple containers in parallel.

[CodeClimate](https://codeclimate.com) provides great metrics about the health of your codebase.

Unfortunately, CodeClimate [only supports a single payload of coverage data](https://docs.codeclimate.com/docs/setting-up-test-coverage#important-fyis) and thus cannot be integrated with CircleCI parallel-test execution without some additional work.

This gem is that additional work.

## Installation

Add this line to your application's Gemfile:

```bash
gem 'codeclimate_circle_ci_coverage', group: 'test'
```

And then add the following to your circle.yml:

```yml
test:
  post:
    - bundle exec report_coverage
```

Add add the following to the top of your spec_helper.rb:
```ruby
# run coverage when on CI
if ENV['CI']
  require 'simplecov'
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

Once your test suite has been run on the `master` branch, there will be a "Test Coverage" link appear in your CodeClimate feed, as well as on the Sidebar.

**Note** CodeClimate will **only** report coverage metrics on the default branch. Thus, running this on a feature branch will not cause coverage numbers to be reported.

## Configuration

If your default branch is not `master`, you'll have to tell `report_coverage` the the branch name. Coverage will be reported whenever specs are run for this branch. (by default, the branch is `master`)

```yml
test:
  post:
    - bundle exec report_coverage --branch develop
```

## Known Issues

There is (a bug)[https://github.com/colszowka/simplecov/pull/441] in SimpleCov which prevents results from merging cleanly. A patch has been applied to resolve this, but new versions of SimpleCov may cause the patch to break. Currently known to work with SimpleCov version 0.11.2.

## Similar Projects

- https://github.com/grosser/codeclimate_batch - TravisCI Integration
- https://github.com/crazydog115/simplecov-s3 - Combines Coverage reports using AWS S3 storage
- https://github.com/mikz/codeclimate-parallel-test-reporter

## Credits

CodeClimate CircelCI Coverage was written by (Robin Dunlop)[https://github.com/rdunlop], based extensively on:

- https://github.com/codeclimate/ruby-test-reporter/issues/10
- https://gist.github.com/evanwhalen/f74879e0549b67eb17bb

