Gem::Specification.new do |s|
  s.name = 'cielo'
  s.version = '1.0.1'

  s.require_paths = ['lib']
  s.authors = ['Crafters Software Studio', 'Felipe Rodrigues']
  s.date = '2016-01-19'
  s.description = "Integração com a cielo"
  s.email = 'crafters@crafters.com.br'
  s.extra_rdoc_files = [
    'LICENSE.txt',
    'README.rdoc'
  ]

  s.homepage = 'http://github.com/crafters/cielo'
  s.licenses = ['MIT']
  s.rubygems_version = '2.5.1'
  s.summary = 'Integração com a cielo'

  s.add_dependency('activesupport', ['>= 3.2.22'])
  s.add_dependency('builder')
  s.add_dependency('bundler')
  s.add_dependency('rake')
  s.add_development_dependency('shoulda')
  s.add_development_dependency('rspec')
  s.add_development_dependency('vcr')
  s.add_development_dependency('webmock')
end
