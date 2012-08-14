$commands.all << {
    name: 'clone',
    help: 'Creates a copy of a repository.',
    usage: 'ez clone <source_url> [<destination_directory>]',
    options: [],
    action: lambda do |opts, args|
      $commands.git.clone(args)
    end
}