$commands.all << {
    name: 'switch!',
    help: 'Abandon all changes and switch to the given branch.',
    usage: 'ez switch! <branch_name>',
    options: [
        [:force, 'Automatically approve and bypass the confirmation prompt.', short: '-f']
    ],
    action: lambda do |opts, args|
      opts[:switch!] = true
      $commands.git.switch!(opts, args)
    end
}