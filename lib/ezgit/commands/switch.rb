$commands.all << {
    name: 'switch',
    help: 'Switch to the given branch if there are not changes.',
    usage: 'ez switch <branch_name>',
    options: [],
    action: lambda do |opts, args|
      opts[:switch] = true
      $commands.git.switch!(opts,args)
    end
}
