# Scrutinizer Ocular

Uploads Ruby code coverage data to [scrutinizer-ci.com](https://scrutinizer-ci.com). Internally, it relies on SimpleCov.


## Installation

Add this line to your application's Gemfile:

    gem 'scrutinizer-ocular'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install scrutinizer-ocular

## Usage

You need to initialize ocular at the very top of your ``test_helper.rb`` or ``spec_helper.rb`` file 
before loading any of your code:

```ruby
# test_helper.rb or spec_helper.rb
require 'scrutinizer/ocular'
Scrutinizer::Ocular.watch!
```

When running your tests on a private repository, make sure you have your access token set:

```bash
SCRUTINIZER_ACCESS_TOKEN=abc123 bundle exec rspec spec
```

When you [create an access token](https://scrutinizer-ci.com/profile/applications), make sure to select ``READ`` permission only.
Generally, it's a good idea to set-up a dedicated user for reporting code coverage only.

## Advanced Use-Cases

### Defining the SimpleCov Profile
If you would like to have SimpleCov use a specific profile, you can pass it to the watch method:

```ruby
Scrutinizer::Ocular.watch! 'rails'
```

### Adding additional Formatters
If you would like to run other formatters apart from Scrutinizer's Formatter, you can add these easily:

```ruby
require 'simplecov'
require 'scrutinizer/ocular'

# To avoid uploading coverage when running tests locally, you can use
# Scrutinizer::Ocular.should_run? and add the formatter conditionally.

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
  SimpleCov::Formatter::HTMLFormatter,
  Scrutinizer::Ocular::UploadFormatter
]
SimpleCov.start
```

### Merging Coverage from Parallelized Runs
There is nothing you need to change in your set-up. You can just make multiple code coverage
submissions to Scrutinizer and make sure to 
[adjust your .scrutinizer.yml](https://scrutinizer-ci.com/docs/tools/external-code-coverage/)
to tell us how many you are going to send.

## Credits
Parts of this code were inspired by the Ruby Coveralls implementation and were received under the MIT license.