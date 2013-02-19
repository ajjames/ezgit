$commands.all << {
    name: 'commit',
    help: 'Creates a commit for all current file changes.',
    usage: 'ez commit "message"',
    options: [],
    action: lambda do |opts, args|
      Processor.new(opts).commit(args)
    end
}