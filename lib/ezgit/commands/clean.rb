$commands.all << {
    name: 'clean!',
    help: 'Bypasses the prompt.',
    usage: '',
    options: [
        [:force, 'Automatically approve and bypass the confirmation prompt.', short: '-f', default: true]
    ],
    action: lambda do |opts, args|
      Processor.new(opts).clean!(false)
    end
}

$commands.all << {
    name: 'clean',
    help: 'Wipes untracked files unless they are marked as ignored(via .gitignore).',
    usage: '',
    options: [],
    action: lambda do |opts, args|
      Processor.new(opts).clean!(false)
    end
}
