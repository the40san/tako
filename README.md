# Tako
[![CircleCI](https://circleci.com/gh/the40san/tako/tree/master.svg?style=svg)](https://circleci.com/gh/the40san/tako/tree/master)

Provides features for Database Sharding in ActiveRecord.
The main goal of tako is implementing sharding features with less ActiveRecord-dependent, catching up Rails version up.
Rails 5 Ready.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'tako'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install tako

## Usage
## How to use Tako?
First, you need to create a config file, shards.yml, inside your config/ directory.
Also you can override config file path with environment variable.

### Syntax
Tako adds a method to each AR Class and object: the shard method is used to select the shard like this:

```ruby
  User.shard(:slave_one).where(:name => "Thiago").limit(3)
```

Tako also supports queries within a block. When you pass a block to the shard method, all queries inside the block will be sent to the specified shard.

```ruby
Tako.shard(:slave_two) do
  User.create(:name => "Mike")
end

# or

ModelA.shard(:slave_two) do
  User.create(:name => "Mike")
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

### Run test

Run `bundle exec rake` to run rspec

Run `bundle exec rake` in `spec/dummy5` will run rspec with rails 5

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/the40san/tako. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

