# CodeClimate CircleCI Coverage

[![Code Climate](https://codeclimate.com/github/rdunlop/codeclimate_circle_ci_coverage.png)](https://codeclimate.com/github/rdunlop/codeclimate_circle_ci_coverage)
[![Gem](https://img.shields.io/gem/v/codeclimate_circle_ci_coverage.svg)](https://rubygems.org/gems/codeclimate_circle_ci_coverage)
[![Gem](https://img.shields.io/gem/dt/codeclimate_circle_ci_coverage.svg)](https://rubygems.org/gems/codeclimate_circle_ci_coverage)

[CircleCI](https://circleci.com) provides a great CI environment, and allows your test suite to be run in multiple containers in parallel.

[CodeClimate](https://codeclimate.com) provides great metrics about the health of your codebase.

Unfortunately, CodeClimate [only supports a single payload of coverage data](https://docs.codeclimate.com/docs/setting-up-test-coverage#important-fyis) and thus cannot be integrated with CircleCI parallel-test execution without some additional work.

This gem does that "additional work" by performing the following:
- After all of the CI nodes are complete, it copies the SimpleCov file from each node of CI onto the first node.
- It then uses SimpleCov to merge the results together into a single result file
- It then provides that file to `codeclimate-test-reporter` as a single payload

## Installation

### Adding the Gem to your system
Add this line to your application's Gemfile:

```bash
gem 'codeclimate_circle_ci_coverage', group: 'test'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install codeclimate_circle_ci_coverage

### Collecting Metrics during your CircleCI Test Run

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

### Invoking the Gem after your CircleCI Test Run

Add the following to your circle.yml:

```yml
test:
  post:
    - bundle exec report_coverage
```

## CircleCI Configuration

In order for CircleCI to send coverage information to CodeClimate, it must have your CodeClimate access token.

In CircleCI, add the `CODECLIMATE_REPO_TOKEN` to your Environment Variables.

You can find your `CODECLIMATE_REPO_TOKEN` when logged into CodeClimate:
-> "Settings" -> "Test Coverage" -> "Ruby"

## Usage

CircleCI will now aggregate together all of your individual coverage metrics into a single file, and then upload that file to CodeClimate.

Once your test suite has been run on the configured branch (`master` by default), there will be a "Test Coverage" link appear in your CodeClimate feed, as well as on the Sidebar.

**Note** CodeClimate will **only** report coverage metrics on the configured branch. Thus, running this on a feature branch will not cause coverage numbers to be reported.  This is a limitation of the Code Climate Coverage reporting.

## Running Coverage Locally

If you want to run specs locally and see the coverage, you can do so by setting the `CI` environment variable before executing your tests.

For example, if you are running rspec:

```sh
CI=true bundle exec rspec spec
```

## Configuration

If your default branch is not `master`, you'll have to tell `report_coverage` the the branch name. Coverage will be reported whenever specs are run for this branch. (by default, the branch is `master`)

```yml
test:
  post:
    - bundle exec report_coverage --branch develop
```

## Known Issues

There is [a bug](https://github.com/colszowka/simplecov/pull/441) in SimpleCov which prevents results from merging cleanly. A patch has been [applied to this codebase](https://github.com/rdunlop/codeclimate_circle_ci_coverage/blob/master/lib/codeclimate_circle_ci_coverage/patch_simplecov.rb) to resolve this, but new versions of SimpleCov may cause the patch to break. Currently known to work with SimpleCov version 0.11.2.

## Similar Projects

- https://github.com/grosser/codeclimate_batch - TravisCI Integration
- https://github.com/crazydog115/simplecov-s3 - Combines Coverage reports using AWS S3 storage
- https://github.com/mikz/codeclimate-parallel-test-reporter

## Credits

CodeClimate CircelCI Coverage was written by [Robin Dunlop](https://github.com/rdunlop), based extensively on:

- https://github.com/codeclimate/ruby-test-reporter/issues/10
- https://gist.github.com/evanwhalen/f74879e0549b67eb17bb

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/rdunlop/codeclimate_circle_ci_coverage.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

