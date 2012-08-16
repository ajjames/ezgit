$commands.all << {
    name: 'pull',
    help: 'Synchronizes the current branch with the remote.',
    options: [],
    action: lambda do |opts, args|
      $commands.git.pull
    end
}