Gem::Specification.new do |s|
  s.name = "cielo"
  s.version = "0.2.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Crafters Software Studio", "Felipe Rodrigues"]
  s.date = "2016-01-19"
  s.description = "Integra\u{e7}\u{e3}o com a cielo"
  s.email = "crafters@crafters.com.br"
  s.extra_rdoc_files = [
    "LICENSE.txt",
    "README.rdoc"
  ]
  
  s.homepage = "http://github.com/crafters/cielo"
  s.licenses = ["MIT"]
  s.rubygems_version = "2.5.1"
  s.summary = "Integra\u{e7}\u{e3}o com a cielo"

  s.add_dependency('activesupport', [">= 4.2.5"])
  s.add_dependency('builder', [">= 3.2.0"])
  s.add_dependency('bundler')
  s.add_dependency('rake')
  s.add_development_dependency('watir-webdriver')
  s.add_development_dependency('shoulda')
  s.add_development_dependency('rspec')
  s.add_development_dependency('fakeweb')
end

