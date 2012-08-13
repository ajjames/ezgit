require 'ezgit/string'

class Git

	def initialize(global_options)
		@dry_run = global_options[:dry_run]? '-n' : ''
	end


	def log_graph(count = 5)
    puts ''
		puts "REPOSITORY TREE".white.bold +  "(last #{count} commits)"
    puts `git log --graph --all --format=format:'%C(bold)%h%C(reset) %C(bold green)(%cr)%C(reset) %C(bold white)%cn%C(reset) %C(white)%s%C(reset)%C(bold yellow)%d%C(reset)' --abbrev-commit --date=relative -n #{count}`
	end


  def branch
    puts ''
    puts 'BRANCHES'.white.bold
    system('git branch -a')
  end


  def status
    puts ''
    puts 'STATUS'.white.bold
    system('git status')
  end


  def reset_hard
    if not @dry_run.empty?
      puts 'Ignoring hard reset.'
      return
    end
    puts `git reset --hard`
  end


	def clean
    puts `git clean -df #{@dry_run}`
	end


  def clean!
    puts `git  clean -dfx #{@dry_run}`
  end


	def checkout(opts, args)

	end


end