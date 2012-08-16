$commands.all << {
    name: 'switch',
    help: 'Switch to the given branch',
    usage: 'ez switch <branch_name>',
    options: [],
    action: lambda do |opts, args|
      $commands.git.checkout(args)
    end
}