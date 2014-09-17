# ConnectwiseSdk

An SDK allowing integration into Connectwise

## Installation

Add this line to your application's Gemfile:

    gem 'connectwise_sdk'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install connectwise_sdk

## Usage

Sample Usage:

### Using the low level connection object directly

   conn = Connectwise::Connection.new host: 'host.domain.com', company\_name: 'company', integrator\_login\_id: 'username', integrator\_password: 'password'
   conn.call :contact, :find\_contacts, conditions: 'EmailAddress like "test@test.com"'

The first parameter in the call method is the api

## Current progress and TODOs

Currently only the contact and member classes are done

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

### Adding support for other Connectwise Classes

There is a Model Module that incorporates the core of what it is to be
connectwise model. Every Model should include this class.
