lib = File.expand_path(File.join(File.dirname(__FILE__), 'lib'))
$:.unshift lib unless $:.include?(lib)

require 'open_dsl'

Gem::Specification.new do |s|
  s.name        = "open_dsl"
  s.version     = OpenDsl::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Ian Leitch"]
  s.email       = ["port001@gmail.com"]
  s.homepage    = "http://github.com/ileitch/open_dsl"
  s.summary     = "A simple DSL library that extends your existing classes."
  s.description = "Open DSL is a DSL (Domain Specific Language) builder which aims to provide a highly readable DSL and the flexibility to integrate with existing Classes in your system. Open DSL uses OpenStructs internally when creating collections of attributes.. hence the name :)"

  s.required_rubygems_version = ">= 1.3.6"

  s.add_development_dependency "rspec"

  s.files        = Dir.glob("{bin,lib}/**/*") + %w(LICENSE README.rdoc)
  s.require_path = 'lib'
end
