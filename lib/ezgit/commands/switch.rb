$commands.all << {
    name: 'switch!',
    help: 'Abandon all changes and switch to the given branch.',
    usage: 'ez switch! <branch_name>',
    options: [
        [:force, 'Automatically approve and bypass the confirmation prompt.', short: '-f']
    ],
    action: lambda do |opts, args|
      Processor.new(opts).switch!('switch!', args)
    end
}


$commands.all << {
    name: 'switch',
    help: 'Switch to the given branch if there are not changes.',
    usage: 'ez switch <branch_name>',
    options: [],
    action: lambda do |opts, args|
      Processor.new(opts).switch!('switch',args)
    end
}
