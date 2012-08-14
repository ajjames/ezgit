$commands.all << {
    name: 'update',
    help: 'Attempts to self-update from rubygems.org.',
    options: [],
    action: lambda do |opts, args|
      system('gem install ezgit; gem cleanup --verbose ezgit')
      exit
    end
}