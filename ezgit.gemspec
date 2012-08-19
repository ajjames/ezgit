require File.expand_path("lib/ezgit/version.rb")

Gem::Specification.new do |s|
  s.name         = 'ezgit'
  s.files        = Dir["{lib}/**/*.rb", "bin/*", "LICENSE", "*.md"]
  s.require_path = 'lib'
  s.version      = Ezgit::VERSION
  s.date         = Time.now.strftime("%y-%m-%d")
  s.summary      = 'ezgit'
  s.description  = 'EZGit is a simple interface for working with git repositories'
  s.authors      = ['AJ James']
  s.email        = 'ajjames@msn.com'
  s.homepage     = 'http://github.com/ajjames/ezgit'
  s.license      = 'MIT'
  s.executables  << 'ez'
end