$commands.all << {
    name: 'delete!',
    help: 'Bypasses the prompt.',
    usage: '',
    options: [
        [:force, 'Automatically approve and bypass the confirmation prompt.', short: '-f', default: true]
    ],
    action: lambda do |opts, args|
      Processor.new(opts).delete!(args)
    end
}

$commands.all << {
    name: 'delete',
    help: 'Completely delete a given branch, both locally and on the remote.',
    usage: 'ez delete <branch_name>',
    options: [],
    action: lambda do |opts, args|
      Processor.new(opts).delete!(args)
    end
}