$commands.all << {
    name: 'goto!',
    help: 'Move to the location in the tree specified by a commit id. All changes will be lost.',
    usage: 'ez goto! <commit>',
    options: [
        [:force, 'Automatically approve and bypass the confirmation prompt.', short: '-f']
    ],
    action: lambda do |opts, args|
      $commands.git.goto!(opts, args)
    end
}