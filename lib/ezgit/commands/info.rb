$commands.all << {
    name: 'info',
    help: 'Shows files status and current branches.',
    options: [
        [:verbose, 'Show all the nitty-gritty details', short: '-v'],
        [:test, 'see if this works', default: 'itworks']
    ],
    action: lambda do |opts, args|
      $commands.git.log_graph
      $commands.git.branch
      $commands.git.status
    end
}