# RestashRails

This gem is sending Json structured logs from your Rails app to destination you define.
We propose Logstash as a receiver. <br>
Logs sent via TCP socket with timeout, you'll define or with default of 10ms 

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'restash_rails'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install restash_rails

## Usage
Data is written to host and port you provide via configs. 
We open TCP socket with timeout option you provide.
We send it in json format. So the logstash is one of the receivers you can use, 
without any special config.
We also let you to path yours app custom exceptions and there statuses.
If you not, gem won't be possible to translate an exception to an appropriate status.
As a result, some responses will be logged without an exception status
Pay attention that we won't let you override Rails native exceptions statuses.

##### In application.rb

```ruby
#Restahs rails won't work unless you enable it
config.restash_rails.enabled = true

#If you want to leave original Rails Logs
config.restash_rails.keep_original_logs = true

#Host and port the data will be sent to 
config.restash_rails.host = '127.0.0.1'
config.restash_rails.port = '9200'

#TCP Timeout options
config.restash_rails.timeout_options = {connect_timeout: DEFAULT_TIMEOUT, write_timeout: DEFAULT_TIMEOUT, read_timeout: DEFAULT_TIMEOUT}

#exception_statuses 
error_401 = {:status => 401, :types => [Exceptions::AccessDenied, Exceptions::MyException]}
error_422 = {:status => 422, :types => [Exceptions::InvalidParams]}
config.exception_statuses = [error_401, error_422]
```

All those configs can also be paassed as yaml file
```ruby
RESTASH_RAILS_CONF =  YAML::load(PATH_TO_YOUR_CONFIG_FILE)
config.restash_rails = RESTASH_RAILS_CONF[Rails.env]
```
## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/YotpoLtd/restash-rails. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

