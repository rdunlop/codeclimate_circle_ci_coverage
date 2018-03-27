# CodeClimate CircleCI Coverage

[![Code Climate](https://codeclimate.com/github/rdunlop/codeclimate_circle_ci_coverage.png)](https://codeclimate.com/github/rdunlop/codeclimate_circle_ci_coverage)
[![Gem](https://img.shields.io/gem/v/codeclimate_circle_ci_coverage.svg)](https://rubygems.org/gems/codeclimate_circle_ci_coverage)
[![Gem](https://img.shields.io/gem/dt/codeclimate_circle_ci_coverage.svg)](https://rubygems.org/gems/codeclimate_circle_ci_coverage)

[CircleCI](https://circleci.com) provides a great CI environment, and allows your test suite to be run in multiple containers in parallel.

[CodeClimate](https://codeclimate.com) provides great metrics about the health of your codebase.

Unfortunately, CodeClimate [only supports a single payload of coverage data](https://docs.codeclimate.com/docs/setting-up-test-coverage#important-fyis) and thus cannot be integrated with CircleCI parallel-test execution without some additional work.

This gem does that "additional work" by performing the following:
- After all of the CI nodes are complete, it gathers the SimpleCov file from each node of CI onto the first node.
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

#### Circle CI 1.0

Add the following to your circle.yml:

```yml
test:
  post:
    - bundle exec report_coverage
```

#### Circle CI 2.0

In order to pass the test results from each node, on Circle CI 2.0, more steps must be done:

1) Create a Circle CI API Key

- From the Project Settings -> API Permissions
- "Create Token", scope: 'view-builds' ("Build Artifacts")
- Set an "Environment Variable" with "CIRCLE_TOKEN" with this token.

2) Make each node upload the coverage file to artifacts for use.

- Add to `.circleci/config.yml` the following
```
- store_artifacts:
    path: coverage/.resultset.json
    prefix: coverage # must be called coverage to be picked up by the report_coverage script
```

The coverage_reporter.rb will use the Circle CI API in order to download the .resultset.json from node to combine them.

Add the following to your config.yml

We use a `deploy` stage so that it is only run once all of the (possibly parallel) executors have run.

```yml
- deploy:
    name: Merge and copy coverage data
    command: bundle exec report_coverage
```


## CircleCI Configuration

In order for CircleCI to send coverage information to CodeClimate, it must have your CodeClimate access token.

1. Find your `CODECLIMATE_REPO_TOKEN` by going to your project in CodeClimate. Then look under:
   "Settings" -> "Test Coverage" -> "Ruby"
1. In CircleCI, go to your Project Settings, click on "Environment Variables", and then "Add Variable". Enter
   `CODECLIMATE_REPO_TOKEN` as the name, and enter the value you found in the previous step.

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
bundle exec report_coverage --branch develop
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
- https://gist.github.com/leemachin/1aeb217d989f3981cc3f06d88938bd33 by way of https://discuss.circleci.com/t/code-coverage-and-parallel-builds/12330/2

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/rdunlop/codeclimate_circle_ci_coverage.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

