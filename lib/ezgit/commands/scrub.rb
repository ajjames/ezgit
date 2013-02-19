require 'ezgit/processor'

$commands.all << {
    name: 'scrub!',
    help: 'Bypasses the prompt.',
    options: [
        [:force, 'Automatically approve and bypass the confirmation prompt.', short: '-f', default: true]
    ],
    action: lambda do |opts, args|
      Processor.new(opts).clean!(true)
    end
}

$commands.all << {
    name: 'scrub',
    help: 'Wipes untracked files including ignored files.',
    options: [],
    action: lambda do |opts, args|
      Processor.new(opts).clean!(true)
    end
}
