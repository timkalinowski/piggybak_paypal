$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "piggybak_paypal/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "piggybak_paypal"
  s.version     = PiggybakPaypal::VERSION
  s.authors     = ["Timmy Crawford"]
  s.email       = ["timmydcrawford@gmail.com"]
  s.homepage    = "http://github.com/timmyc"
  s.summary     = "PayPal Payment Calculator for Piggybak"
  s.description = "Collect muneez via PayPal on Piggybak.  That is alot of P's plz."

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 3.2.13"
  # s.add_dependency "jquery-rails"

  s.add_development_dependency "sqlite3"
end
