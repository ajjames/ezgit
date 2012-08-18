$commands.all << {
    name: 'clean!',
    help: 'Wipes all untracked and ignored files.',
    options: [
        [:force, 'Automatically approve and bypass the confirmation prompt.', short: '-f']
    ],
    action: lambda do |opts, args|
      $commands.git.clean!(true, opts)
    end
}