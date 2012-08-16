$commands.all << {
    name: 'commit',
    help: 'Creates a commit for all current file changes.',
    usage: 'ez commit "message"',
    options: [],
    action: lambda do |opts, args|
      $commands.git.commit(args)
    end
}