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

```ruby
conn = Connectwise::Connection.new host: 'host.domain.com', company_name: 'company', integrator_login_id: 'username', integrator_password: 'password'
contact = Connectwise::Contact.new(conn, first_name: 'Malcom', last_name: 'Reynolds', email: 'captain@serenity.com')
contact.save  # => creates a new contact and updates itself with the fields set by connectwise
contact.id    # => 432

# Retrieve a list of members
member = Connectwise::Member.where(conn, email_address: 'captain@serenity.com')
```

### Using the low level connection object directly

In the event that a certain api you need to access isn't fully supported by the sdk yet, or if you simply want more direct access to the api, you can use the lower level call method on the connection object.

```ruby
conn = Connectwise::Connection.new host: 'host.domain.com', company_name: 'company', integrator_login_id: 'username', integrator_password: 'password'
conn.call :contact, :find_contacts, conditions: 'EmailAddress like "test@test.com"'
```

 - The first parameter is the api you wish to use.  In this case the `contactApi`.  
 - The second parameter is the specific api call you wish to use (from the Connectwise Api documentation)
 - The third paramater is the data you wish to send the api

The connection object will add the credential fields to your api call automatically, and convert the data hash into a SOAP request.  Note that because there is some inconsistency in the naming / case used by the api, all data fields must be passed as specified by the api and not in standard Ruby snake case.  For example:

```ruby
conn.call :contact, :add_or_update_contact, {contact: {
        FirstName: contact.first_name,
        LastName: contact.last_name,
        Email: contact.email,
        Phone: contact.phone,
        }}
```

Note how `contact` is lower case, while `FirstName` and the other fields are camel case with a leading capital. The Connectwise api requires that contact be lower case and the others camel case.

## Current progress and TODOs

Currently only the `Member.where` method, and the low level `Connection.call` method are working.

1. Complete Contact class
2. Company class
3. Opportunity class
4. Ticket class
5. Remaining api

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

### Adding support for other Connectwise Classes

There is a `Connectwise::Model` module that incorporates the core of what it is to be
connectwise model. Every Model should include this class.

Then it's a matter of figuring out the following for each class:
- What fields are returned from a find call
- What fields are returned from a create call (sometimes this differs from the find call)
- Adding these fields to the attr_accessible list to define what parameters are valid
- Handling the basic CRUD operations by using the connection object

Some issues that need to be resolved:
- How best to handle nested data structures (A contact has an email address list, a phone number list, etc.)
- How best to handle nested objects (A company has a contact)
