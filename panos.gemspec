Gem::Specification.new do |s|
    s.name             = 'panos'
    s.version          = '0.0.1'
    s.date             = '2016-09-28'
    s.license          = ''
    s.summary          = 'PAN-OS gem'
    s.description      = 'A Ruby gem to interact with a Palo Alto/Panorama firewall'
    s.authors          = ['Kevin Griffith']
    s.email            = 'kpgriffith@me.com'
    s.require_paths    = ['lib']
    s.executables      = %w()
    s.required_ruby_version = '>= 2.0.0'

    s.platform         = Gem::Platform::RUBY
    s.extra_rdoc_files = %w()

    s.files            = %w() + ['panos.gemspec'] + ['Gemfile'] + Dir.glob('lib/**/*') + Dir.glob('bin/**/*')
    s.test_files       = %w() + Dir.glob('test/**/*') + Dir.glob('spec/**/*')

    s.add_development_dependency 'rake', '~> 10.0'
    s.add_development_dependency 'rspec', '~> 3.5.0'
    s.add_development_dependency 'simplecov', '~> 0.12.0'
    s.add_development_dependency 'codeclimate-test-reporter'
    s.add_dependency 'crack', '= 0.4.3'
    s.add_dependency 'rest-client', '~> 2.0.0'

end
