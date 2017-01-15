# ParamCheck

[![CircleCI](https://circleci.com/gh/cjmarkham/param_check.svg?style=svg&circle-token=ff228fe4c2537fd6baf7b4370d813aee2fc5cb88)](https://circleci.com/gh/cjmarkham/param_check)
[![codecov](https://codecov.io/gh/cjmarkham/param_check/branch/master/graph/badge.svg?token=VPkZR1Im62)](https://codecov.io/gh/cjmarkham/param_check)


Easily validate params for API methods.
Are you sick of writing `respond_with(error) unless params[:foo].present?`? With ParamCheck, you can abstract
all of the validation.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'param_check'
```

And then execute:

    $ bundle

## Usage

### Validating presence
By default, a parameter is not required unless you specify the `required: true` option

```ruby
def index
  param! :foo, required: true
end
```

```ruby
def index
  param! :foo, required: true do |foo| # params[foo]
    foo.param! :bar, required: true # params[foo][bar]
  end
end
```

### Validating type
```ruby
def index
  param! :foo, type: String
end
```

```ruby
def index
  param! :foo, type: ActionController::Parameters do |foo|
    foo.param! :bar, type: Integer
    foo.param! :baz, type: String
  end
end

# Passes
params[:foo] = {
  bar: 1,
  baz: 'Two',
}

# Fails
params[:foo] = {
  bar: 'One',
  baz: 2,
}
params[:foo] = 'bar'
```

### Validating range
```ruby
def index
  param! :foo, min: 1, max: 3
end
```

### Validating inclusion
```ruby
def index
  param! :foo, in: ['foo', 'bar']
end
```

By default, ParamCheck throws a `ParameterError` exception. You can rescue from this exception in order to
respond with JSON for example:

```ruby
# in API::ApplicationController
rescue_from ParameterError do |e|
  render json: { error: e.message }
end
```

## Options
| Option   | Type    | Default | Values                                         | Description                                |
| -------- | ------- | ------- | ---------------------------------------------- | ------------------------------------------ |
| required | Boolean | false   | true/false                                     | Is the parameter required?                 |
| type     | Class   | nil     | Fixnum/Integer/String/ActionController::Params | Specifies the type the parameter should be |
| min      | Integer | nil     | Any Integer                                    | Specifies the min threshold for the Int    |
| max      | Integer | nil     | Any Integer                                    | Specifies the max threshold for the Int    |
| in       | Array   | nil     | Array                                          | An array of values the param should match  |

## Production sites using this gem
Submit a PR to add your site to the list

[Givey](https://www.givey.com)

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/cjmarkham/param_check. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

