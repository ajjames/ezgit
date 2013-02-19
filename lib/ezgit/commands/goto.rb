$commands.all << {
    name: 'goto!',
    help: 'Bypasses the prompt.',
    usage: '',
    options: [
        [:force, 'Automatically approve and bypass the confirmation prompt.', short: '-f', default: true]
    ],
    action: lambda do |opts, args|
      Processor.new(opts).goto!(args)
    end
}

$commands.all << {
    name: 'goto',
    help: 'Move to the location in the tree specified by a commit id. All changes will be lost.',
    usage: 'ez goto <commit>',
    options: [],
    action: lambda do |opts, args|
      Processor.new(opts).goto!(args)
    end
}