$commands.all << {
    name: 'reset!',
    help: 'Deletes changes in all tracked files. Untracked files will not be affected.',
    options: [
        [:force, 'Automatically approve and bypass the confirmation prompt.', short: '-f']
    ],
    action: lambda do |opts, args|
      $commands.git.reset_hard!(opts)
    end
}