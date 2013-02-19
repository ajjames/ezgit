$commands.all << {
    name: 'info',
    help: 'Shows files status and current branches.',
    usage: '',
    options: [
        [:ignored, 'Lists the files are being ignored.', short: '-i']
    ],
    action: lambda do |opts, args|
      Processor.new(opts).info
    end
}