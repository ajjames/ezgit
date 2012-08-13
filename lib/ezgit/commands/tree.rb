$commands.all << {
    name: 'tree',
    help: 'Shows git tree history for the current branch',
    usage: 'ez tree [number_of_entries]',
    options: [
        [:verbose, 'Show information', short: '-v']
    ],
    action: lambda do |opts, args|
      puts `git log --graph --all --format=format:'%C(bold)%h%C(reset) %C(bold green)(%cr)%C(reset) %C(bold white)%cn%C(reset) %C(white)%s%C(reset)%C(bold yellow)%d%C(reset)' --abbrev-commit --date=relative -n 10`
    end
}