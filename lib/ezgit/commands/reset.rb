$commands.all << {
    name: 'reset!',
    help: 'Bypasses the prompt.',
    usage: '',
    options: [
        [:force, 'Automatically approve and bypass the confirmation prompt.', short: '-f', default: true]
    ],
    action: lambda do |opts, args|
      Processor.new(opts).reset_hard!
    end
}


$commands.all << {
    name: 'reset',
    help: 'Deletes changes in all tracked files. Untracked files will not be affected.',
    usage: '',
    options: [],
    action: lambda do |opts, args|
      Processor.new(opts).reset_hard!
    end
}