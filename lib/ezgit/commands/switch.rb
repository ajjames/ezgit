$commands.all << {
    name: 'switch!',
    help: 'Abandon all changes and switch to the given branch.',
    usage: '',
    options: [
        [:force, 'Automatically approve and bypass the confirmation prompt.', short: '-f', default: true]
    ],
    action: lambda do |opts, args|
      Processor.new(opts).switch!('switch!', args)
    end
}


$commands.all << {
    name: 'switch',
    help: 'Abandon all changes and switch to the given branch.',
    usage: 'ez switch <branch_name>',
    options: [],
    action: lambda do |opts, args|
      Processor.new(opts).switch!('switch!', args)
    end
}
