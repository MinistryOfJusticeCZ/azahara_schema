$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "action_schema/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "action_schema"
  s.version     = ActionSchema::VERSION
  s.authors     = ["Ondřej Ezr"]
  s.email       = ["oezr@msp.justice.cz"]
  s.homepage    = "http://git.justice.cz/libraries/action_schema"
  s.summary     = "Gem to support developement of action schema"
  s.description = "This gem should provide complete tools for quick developement of easy registry app in RoR."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  s.add_dependency "rails", "~> 5.0.2"

  s.add_development_dependency "sqlite3"
end
