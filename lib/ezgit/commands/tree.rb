$commands.all << {
    name: 'tree',
    help: 'Shows git tree history for the current branch',
    usage: 'ez tree',
    options: [
        [:all, 'Shows all branches.', short: '-a'],
        [:number, 'Number of entries to display.', short: '-n', default:20]
    ],
    action: lambda do |opts, args|
      count = args[0] || 20
      $commands.git.display_log_graph(opts[:number], opts[:all])
    end
}