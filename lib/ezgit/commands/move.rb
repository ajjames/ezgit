$commands.all << {
    name: 'move',
    help: 'Switch and move changes to the given branch.',
    usage: 'ez move <branch_name>',
    options: [],
    action: lambda do |opts, args|
      opts[:move] = true
      $commands.git.switch!(opts, args)
    end
}