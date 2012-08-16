$commands.all << {
    name: 'push',
    help: 'Pushes the current branch changes to the remote.',
    options: [],
    action: lambda do |opts, args|
      $commands.git.push
    end
}