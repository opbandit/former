lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'former/version'

Gem::Specification.new do |gem|
  gem.name          = "former"
  gem.version       = Former::VERSION
  gem.authors       = ["Brian Muller"]
  gem.email         = ["bamuller@gmail.com"]
  gem.description   = "Converts HTML to form fields for editing values in the HTML"
  gem.summary       = "Converts HTML to form fields for editing values in the HTML"
  gem.homepage      = "http://github.com/opbandit/former"
  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
  gem.add_dependency("nokogiri", ">= 1.6.0")
  gem.add_development_dependency("rake")
  gem.add_development_dependency("rdoc")
end
