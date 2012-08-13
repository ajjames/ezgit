$commands.all << {
    name: 'info',
    help: 'Shows repo information',
    options: [
        [:verbose, 'Show information', short: '-v']
    ],
    action: lambda do |opts, args|
      exec('git status')
    end
}