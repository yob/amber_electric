Gem::Specification.new do |s|
  s.name              = "amber_electric"
  s.version           = "0.0.1"
  s.summary           = "an API client for Amber Electric (https://amberelectric.com.au)"
  s.description       = "an API client for Amber Electric (https://amberelectric.com.au)"
  s.license           = "MIT"
  s.author            = "James Healy"
  s.email             = ["james@yob.id.au"]
  s.homepage          = "http://github.com/yob/amber_electric"
  s.test_files        = [ "spec/**/*" ]
  s.files             = [ "lib/amber_electric.rb", "CHANGELOG","MIT-LICENSE", "README.md" ]

  s.required_ruby_version = ">=2.2"

  s.add_development_dependency("rake")
  s.add_development_dependency("rspec", "~>3.0")
end
