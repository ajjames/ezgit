$commands.all << {
    name: 'delete!',
    help: 'Completely delete a given branch.',
    usage: 'ez delete! <branch_name>',
    options: [
        [:force, 'Automatically approve and bypass the confirmation prompt.', short: '-f']
    ],
    action: lambda do |opts, args|
      $commands.git.delete!(opts,args)
    end
}