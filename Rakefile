require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "sinatra_resource"
    gem.summary = %Q{RESTful actions with Sinatra and MongoMapper}
    gem.description = %Q{A DSL for creating RESTful actions with Sinatra and MongoMapper. It embraces the Resource Oriented Architecture as explained by Leonard Richardson and Sam Ruby.}
    gem.email = "djames@sunlightfoundation.com"
    gem.homepage = "http://github.com/djsun/sinatra_resource"
    gem.authors = ["David James"]

    gem.add_dependency 'djsun-mongo_mapper', '>= 0.5.8.2', '< 0.6'
    gem.add_dependency 'mongo', '>= 0.16', '< 1.0'
    gem.add_dependency 'sinatra', '>= 0.9.4', '< 1.0'
    gem.add_dependency 'query_string_filter', '>= 0.1.2'

    gem.add_development_dependency 'crack', '>= 0.1.4'
    gem.add_development_dependency 'djsun-context', '>= 0.5.6'
    gem.add_development_dependency 'jeremymcanally-pending', '>= 0.1'
    gem.add_development_dependency 'rspec', '>= 1.2.9'
    gem.add_development_dependency 'yard', '>= 0.2.3.5'

    # gem is a Gem::Specification ...
    # ... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install with: gem install jeweler"
end

task :default => :spec

Dir.glob(File.dirname(__FILE__) + '/tasks/*.rake').each { |f| load f }
