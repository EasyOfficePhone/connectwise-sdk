# ConnectwiseSdk

An SDK simplifying integration with the Connectwise API.

The Connectwise (CW) XML Api can be a challenge to work with.  This Sdk aims to simplify this interaction with objects mirroring the CW objects, and applying the standard Ruby conventions to that naming.  While much of the heavy lifting is done by using Savon, there are a number of inconsistecies which this Sdk aims to smooth over.

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

Currently the low level `Connection.call` method is working, as well as basic Member, Contact, Company, and Opportunity creation, and search.

Remaining items include:

1. Support Notes for Opportunities (submitting them)
2. Creating a Facade layer so that the connection object doesn't need to be passed to each object
3. Supporting a late binding way of accessing internal objects (accessing the company object within an opportunity for example)
4. Supporting an intuitive way of accessing lists of phone numbers, addresses, and email addresses, while still allowing simple access to the first one of each.
5. Better support for the difference between a find (summary info only) and a get (full object). This should be hidden by the api
6. A reload facitily to requery for the data.
7. Remaining api

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

### Adding support for other Connectwise Classes

There is a `Connectwise::Model` module that incorporates the core of what it is to be
connectwise model. Every Model should include this class.  See below for a description of it's capabilities.

Then it's a matter of figuring out the following for each class:
- What fields are returned from a find call
- What fields are returned from a create call (sometimes this differs from the find call)
- Adding these fields to the attr_accessible list to define what parameters are valid
- Handling the basic CRUD operations by using the connection object

Some issues that need to be resolved:
- How best to handle nested data structures (A contact has an email address list, a phone number list, etc.)
- How best to handle nested objects.  These are handled for object creation, but accessing them should lazily load the object, making the query against CW only when necessary.
- How best to handle the difference between find and get calls. With CW, a find returns a stub object returned by a get call.  For example, a find on a contact may return an email address, but the get call will return an array of connection objects, each with a different email address in it.  Currently these lists are ignored, but we'll need to deal with them eventually. The initial implementation can make the first email address in the list be returned from an email call, while emails will return the full list.

### Connectwise::Model

The connectwise model centralizes the common actions that are supported by each model object, and creates a small DSL for creating. These actions include support for `.where`, `.find`, `.save`, `.destroy`, and `.persisted?`.  In general the key to supporting these follows a common pattern:

1. Place the api call using the correct model name ('XXXApi' for example, 'ContactApi' for a Contact object).
2. Place the api call using the correct method name ('add_or_update_XXX' for example, 'add_or_update_contact' for a Contact object).
3. Place the parameters inside the correct parent object (e.g. contact: {FirstName: 'first', LastName: 'Last'}}
4. The where clause does a search converting thobject, and one that is generally inconsistent with the e hash parameters into a query string, and then removing the root element from the return hash.
5. The find clause does a get using an id.
6. The save calls use the 'add_or_update_XXX' actions, while the destroy calls use the 'delete_XXX' calls.
7. Persistence is determined by the presence of an id.

The main challenge is getting this to work is allowing enough hooks to customize the model name, plural form of the model name, and the specific api method names in the rare cases that require it.

The final piece is translating the data returned by CW to the data in this API.  For the most part the conversion is straight forward, but part of the purpose of the high level api is to remove the inconsistencies as much as possible.

So while getting a member's email is done with `.email_address`, a contact's email is retrieved with `.email`.  This should be consistent, or better yet, both should work in either case.
