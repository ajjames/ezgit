require File.expand_path("lib/ezgit/version.rb")

Gem::Specification.new do |s|
  s.name         = 'ezgit'
  s.files        = Dir["{lib}/**/*.rb", "bin/*", "LICENSE", "*.md"]
  s.require_path = 'lib'
  s.version      = Ezgit::VERSION
  s.date         = '2012-08-11'
  s.summary      = "ezgit"
  s.description  = "ezgit is a simple interface for working with git repositories"
  s.authors      = ["AJ James"]
  s.email        = 'ajjames@msn.com'
  # s.homepage     = 'http://rubygemgem.org/gems/ezgit'
  s.executables  << 'ez'
end