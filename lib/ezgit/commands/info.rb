$commands.all << {
    name: 'info',
    help: 'Shows files status and current branches.',
    options: [
        [:ignored, 'Lists the files are being ignored.', short: '-i']
    ],
    action: lambda do |opts, args|
      puts '________________________________'
      puts ''
      puts "        EZGit info".bold
      $commands.git.log_graph
      $commands.git.branch
      $commands.git.status(opts)
      puts '________________________________'
    end
}