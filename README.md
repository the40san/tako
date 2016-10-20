# Tako
[![CircleCI](https://circleci.com/gh/the40san/tako/tree/master.svg?style=svg)](https://circleci.com/gh/the40san/tako/tree/master)

Tako provides Database-Sharding features for ActiveRecord.
Respecting [Octopus](https://github.com/thiagopradi/octopus)

# Motivation
The main goal of Tako is　implementing sharding features with less ActiveRecord-dependent; catching up Rails version up.
And also, Tako supports migration from Octopus because it is no longer maintained.


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'tako'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install tako


## Database migration (Rails)

    $ bundle exec rake db:tako:create
    $ bundle exec rake db:tako:migrate

## Usage
## How to use Tako?
First, you need to create a config file, `shards.yml`, inside your config/ directory.
Also you can override config file path with environment variable.

### Syntax
Tako adds a method to each AR Class and object: the shard method is used to select the shard like this:

```ruby
  User.shard(:slave_one).where(:name => "Thiago").limit(3)
  # => Query will run in :slave_one
```

Tako also supports queries within a block. When you pass a block to the shard method, all queries inside the block will be sent to the specified shard.

```ruby
User.create(name: "Bob")
# => Query will run in default connection in database.yml

Tako.shard(:slave_two) do
  User.create(name: "Mike")
  # => Query will run in :slave_two
end

# or

User.shard(:slave_two) do
  User.create(name: "Mike")
  # => Query will run in :slave_two
end
```

## Associations

```
class User < ActiveRecord::Base
  has_many :logs
  has_one :life
end

user = User.shard(:shard01).create(name: "Jerry")

user.logs.create
# => Query will run in :shard01 (same as user)

user.logs << Log.shard(:shard02).new
# => Query will run in :shard02 (careful)

life = user.build_life
life.save!
# => Query will run in :shard01 (same as user)
```

## Vertical Sharding

Add `force_shard` definition to your Vertical-Sharding model

```ruby
class YourModel < ActiveRecord::Base
  force_shard :shard01
end

YourModel.create
# => Query will run in :shard01

Tako.shard(:shard02) do
  YourModel.create
  # => Query will run in :shard01
end
```

## TODO

 * Make more independent　of ActiveRecord implementation.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

### Run test

Run `bundle exec rake` to run rspec

Run `bundle exec rake` in `spec/dummy5` will run rspec with rails 5.0.0.1

Run `bundle exec rake` in `spec/dummy42` will run rspec with rails 4.2.7.1


## Contributing

Contributors are welcome on GitHub at https://github.com/the40san/tako. Documentation contributors also welcome!
This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

