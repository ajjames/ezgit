$commands.all << {
	name: 'info',
    help: 'Shows files status and current branches.',
    options: [
        [:verbose, 'Show information', short: '-v']
    ],
    action: lambda do |opts, args|
    	puts 'CURRENT COMMIT:'
    	puts `git log --graph --all --format=format:'%C(bold)%h%C(reset) %C(bold green)(%cr)%C(reset) %C(bold white)%cn%C(reset) %C(white)%s%C(reset)%C(bold yellow)%d%C(reset)' --abbrev-commit --date=relative -n 1`
    	puts 'BRANCHES:'
    	system('git branch')
    	puts 'STATUS:'
    	system('git status')
    end
}