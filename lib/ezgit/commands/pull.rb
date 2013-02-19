$commands.all << {
    name: 'pull',
    help: 'Pulls the latest changes from the remote.',
    options: [],
    action: lambda do |opts, args|
      Processor.new(opts).pull
    end
}