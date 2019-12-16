# TypeChecker

A gem for supporting the dynamic type-checking of the method input parameters.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'typechecker'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install typechecker

Or install it locally as:

    $ gem install typechecker-VERSION.gem -l

## Usage
```ruby
require "typechecker"

class A
    sig Integer, String, Symbol
    def fun(parameter1, parameter2, parameter3)
        [parameter1, parameter2, parameter3]
    end
end
p A.new.fun(1, "1", :one) # => [1, "1", :one]
p A.new.fun(1, "1", {}) # => Raise an NoMethodError
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/safiir/typechecker. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the typechecker project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/safiir/typechecker/blob/master/CODE_OF_CONDUCT.md).
