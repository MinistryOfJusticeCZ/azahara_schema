# AzaharaSchema

Azahara schema helps you to work with your model view.
Its basic usage is for your index method. But can be used even as a master-detail component.

* It defines filters for you.
* It renders json responses for you
* Defines easy api over you model
* Lets you define your own outputs and manages them for you.

## Usage
Default usage is only for Rails.

You basically need just this:
```ruby
@schema = AzaharaSchema::Schema.new(Model)
```

But you can ovewrite the default behaviour. Just inherit from AzaharaSchema::ModelSchema
```ruby
class UserSchema < AzaharaSchema::ModelSchema
end

UserSchema.new
```

Azahara takes the name of model before Schema and uses it for looking for model class.
Alternatively you can overwrite method ```model``` and let it return class for your model.

## Installation
Add this line to your application's Gemfile:

```ruby
gem 'azahara_schema'
```

And then execute:
```bash
$ bundle
```

Or install it yourself as:
```bash
$ gem install azahara_schema
```

## Contributing
Contribution directions go here.

## License
The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
