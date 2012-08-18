$commands.all << {
    name: 'clean',
    help: 'Wipes all untracked files, but allows ignored files to remain.',
    options: [
        [:force, 'Automatically approve and bypass the confirmation prompt.', short: '-f']
    ],
    action: lambda do |opts, args|
      $commands.git.clean!(false, opts)
    end
}
