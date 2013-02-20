$commands.all << {
    name: 'tree',
    help: 'Shows git tree history for the current branch',
    usage: 'ez tree',
    options: [
        [:current, 'Shows only the current branch. All other branches are filtered out.', short: '-c'],
        [:number, 'Number of entries to display.', short: '-n', default:20]
    ],
    action: lambda do |opts, args|
      count = opts[:number]
      show_all = !opts[:current]
      Processor.new(opts).tree(count, show_all)
    end
}