$commands.all << {
    name: 'tree',
    help: 'Shows git tree history for the current branch',
    usage: 'ez tree [<number_of_entries>]',
    options: [],
    action: lambda do |opts, args|
      count = args[0] || 20
      $commands.git.display_log_graph(count)
    end
}