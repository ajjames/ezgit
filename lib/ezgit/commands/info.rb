$commands.all << {
    name: 'info',
    help: 'Shows files status and current branches.',
    options: [
        [:ignored, 'Lists the files are being ignored.', short: '-i']
    ],
    action: lambda do |opts, args|
      $commands.git.info(opts)
    end
}