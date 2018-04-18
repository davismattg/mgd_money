# MgdMoney
The MGDMoney gem provides a simple interface for converting between currencies 
and performing operations in different currencies.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'mgd_money'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install mgd_money

## Usage

Define the conversion rates between currencies:

    MGDMoney.conversion_rates("USD", { "EUR" => 0.75, "BTC" => 0.0001 })
    
You must specify at least one conversion rate or the gem will not know how to perform
any operations. The gem only supports conversion operations on those specified currencies.

After setting the rates, you can define new MGDMoney objects, which consist of an 
`amount` and a `currency`:

    twenty_dollars = MGDMoney.new(20, "USD")
    ten_eur = MGDMoney.new(10, "EUR")
    
Convert between currencies:

    twenty_dollars.convert_to("EUR")
    => 15.00 EUR
    

Perform arithmetic operations (+, -, *, /) on different currencies

    twenty_dollars + ten_eur
    => 27.50 USD

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/davismattg/mgd_money.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
