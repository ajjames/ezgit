$commands.all << {
    name: 'info',
    help: 'Shows files status and current branches.',
    options: [
        [:ignored, 'Lists the files are being ignored.', short: '-i']
    ],
    action: lambda do |opts, args|
      puts '________________________________'
      puts ''
      puts "  EZGit info".bold
      $commands.git.display_log_graph
      $commands.git.display_branch_list_with_current
      $commands.git.display_current_changes(opts)
      $commands.git.display_sync_status
      puts '________________________________'
    end
}