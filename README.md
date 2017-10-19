[![pipeline status](https://git.servis.justice.cz/libraries/azahara_schema/badges/master/pipeline.svg)](https://git.servis.justice.cz/libraries/azahara_schema/commits/master)

# AzaharaSchema

Azahara schema helps you to work with your model view.
Its basic usage is for your index method. But can be used even as a master-detail component.

* It defines filters for you.
* It renders json responses for you
* Defines easy api over you model
* Lets you define your own outputs and manages them for you.

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


### Defining enabled/disabled filters

In your inherited class you can globally set enabled filter - for azahara not to populate unwanted parameters of your model.
```ruby
self.enabled_filters 'attr_name1', 'attr_name2'
```
Second option is defining those on instance - it is preferable solution and is more straight forward.
Here you can even solve the permissions.
```ruby
def enabled_filters
  filters = ['attr_name1', 'attr_name2']
  filters << 'attr_name3' if User.current.admin?
  filters
end
```
Alternative for it is just black list attributes you do not want to have as filters.
```ruby
def disabled_filters
  to_disable = []
  to_disable << ['attr_name3'] if !User.current.admin?
  to_disable
end
```
Or you can use all those methods together.


## Contributing
Contribution directions go here.

## License
The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
