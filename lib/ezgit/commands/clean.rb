$commands.all << {
    name: 'clean',
    help: 'Wipes untracked files, but allows ignored files to remain.',
    options: [],
    action: lambda do |opts, args|
      $commands.git.clean
    end
}


$commands.all << {
    name: 'clean!',
    help: 'Deletes all changes and files to resemble only what is checked in.',
    options: [
        [:force, 'Automatically approve and bypass the confirmation prompt.', short: '-f']
    ],
    action: lambda do |opts, args|
      $commands.git.clean!(opts)
    end
}