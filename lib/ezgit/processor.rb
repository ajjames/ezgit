require 'open3'
require 'ezgit/git'

class Processor

  def initialize(global_options)
    @git = Git.new(global_options[:dry_run], global_options[:force], global_options[:ignored], global_options[:debug])
  end


  def tree(count = 5, show_all = false)
    @git.display_log_graph(count, show_all)
  end


  def info
    puts '________________________________'
    @git.display_log_graph
    @git.display_branch_list_with_current
    @git.display_current_changes
    @git.display_sync_status
    puts '________________________________'
  end


  def clone(args)
    return puts 'invalid number of arguments. Requires a source. (Destination is optional.)' if args.count < 1 || args.count > 2
    return if @git.dry_run
    puts out = `git clone #{args.first} #{args[1]}`
    repo_name = args[1] || out.split('\'')[1]
    puts 'You have created a copy of ' + args.first.to_s.bold + ' in the ' + repo_name.bold + ' directory.' if $? == 0
  end


  def clean!(wipe_ignored)
    command = 'git clean -df'
    command += 'x' if wipe_ignored
    out, err = @git.call_command(command + 'n')
    puts err.red.bold unless @git.no_prompt
    return puts 'Nothing to clean.'.green if err.empty?
    return if @git.dry_run
    run_lambda_with_prompt do
      puts `#{command}`
    end
  end


  def reset_hard!
    return if @git.dry_run
    puts 'All changes in tracked files will be lost.'.red.bold unless @git.no_prompt
    run_lambda_with_prompt do
      puts `git reset --hard`
    end
  end


  def goto!(args)
    return puts "Please specify a commit id.".yellow.bold if args.count < 1
    return puts "Invalid number of arguments. Please specify only a commit id.".yellow.bold if args.count > 1
    commit_id = args[0].to_s
    return puts "Would go to #{commit_id}" if @git.dry_run
    puts "About to go to #{commit_id}. All changes in tracked files will be lost.".red.bold unless @git.no_prompt
    run_lambda_with_prompt do
      puts `git reset --hard #{commit_id}`
    end
  end


  def create(args)
    return puts 'Please specify a branch name.'.yellow.bold if args.count < 1
    return puts 'Invalid number of arguments. Please specify only a branch name.'.yellow.bold if args.count > 1
    branch_name = args[0].to_s
    return puts "Would create branch: #{branch_name}" if @git.dry_run
    `git checkout -b #{branch_name}`
    @git.display_branch_list_with_current
    display_current_changes
  end


  def delete!(args)
    return puts "Please specify a branch name.".yellow.bold if args.count < 1
    return puts "Invalid number of arguments. Please specify only a branch name.".yellow.bold if args.count > 1
    branch_name = args[0].to_s
    is_master = branch_name.eql?('master') || branch_name.eql?(add_remote_to_branch('master'))
    return puts "Cannot delete ".red + branch_name.red.bold + ".".red if is_master
    branches = []
    is_local = all_branches.include?(branch_name)
    branches << branch_name if is_local
    remote_name = add_remote_to_branch(branch_name)
    is_remote = all_branches.include?(remote_name)
    branches << remote_name if is_remote
    return puts "Cannot delete ".red + branch_name.red.bold + " while you are using it. Please switch to another branch and try again.".red if branches.include?(@git.current_branch)
    return puts "Branch does not exist: ".red + branch_name.red.bold unless branches.any?
    return puts "Would completely delete branches: #{branches.join(',')}" if @git.dry_run
    print "  Are you sure you want to delete '#{branch_name}'(y/n)?".red.bold unless @git.no_prompt
    return unless run_lambda_with_prompt do
      puts `git push --delete #{remote_name.sub('/', ' ')}` if is_remote
      puts `git branch -D #{branch_name}` if is_local
      refresh_branches
      @git.display_branch_list_with_current
    end
  end


#Three modes:
#  :switch  - switch if there are not changes. Otherwise halt!
#  :switch! - clobber all files before switching
#  :move    - move files with switch
  def switch!(mode, args)
    return puts "Please specify a branch name.".yellow.bold if args.count < 1
    return puts "Invalid number of arguments. Please specify only a branch name.".yellow.bold if args.count > 1
    branch_name = args[0].to_s
    return puts "Please specify a valid branch." unless all_uniq_branches.include?(branch_name)
    return puts "Already on branch: #{@git.current_branch.bold}".green if @git.current_branch.eql?(branch_name)
    has_changes, changes = check_local_changes
    #move files with switch
    if mode == 'move'
      x = `git checkout #{branch_name}`
      return
    end
    #switch if there are not changes. Otherwise halt!
    if has_changes && mode == 'switch'
      display_current_changes
      puts "  Cannot switch branches when you have unresolved changes".red
      puts "  Use ".red + "'ezgit switch! <branch>'".red.bold + " to abandon your changes and switch anyway,".red
      puts "  or use ".red + "'ezgit move <branch>'".red.bold + " to move your changes and switch.".red
      return
    end
    #clobber all files before switching
    #respect the -f option
    if has_changes && mode == 'switch!'
      unless @git.no_prompt
        display_current_changes
        puts ''
        print "  WARNING: You may lose changes if you switch branches without committing.".red.bold
      end
      return unless run_lambda_with_prompt do
        @git.no_prompt = true
        x = `git clean -df`
        x = `git checkout -f #{branch_name}`
        return
      end
      x = `git clean -df`
    end
    x = `git checkout -f #{branch_name}`
  end


  def commit(args)
    return puts "Please specify a message.".yellow.bold if args.count < 1
    return puts "Invalid number of arguments. Please specify only a message.".yellow.bold if args.count > 1
    has_changes, changes = check_local_changes
    return puts "There are no changes to commit".yellow.bold unless has_changes
    commit_id = args[0].to_s
    puts `git add -A`
    puts `git commit -m "#{commit_id}"`
  end


  def pull
    @git.fetch
    stat, count = @git.check_remote_status
    case stat
      when :rebase
        if   @git.dry_run
          puts 'would merge changes'
          display_sync_status
          return
        end
        puts `git rebase #{remote_branch}`
        #TODO: CONFLICT HANDLING?
        puts 'TODO: CONFLICT HANDLING?'
      when :behind
        if @git.dry_run
          puts "would reset branch to #{remote_branch}"
          display_sync_status
          return
        end
        puts `git reset --hard #{remote_branch}`
      when :headless
        puts '  You cannot pull unless you are on a branch.'.red.bold
        display_sync_status
        return
    end
    info
  end


  def push
    stat, count = @git.check_remote_status
    if stat.eql?(:rebase) || stat.eql?(:behind)
      puts "  The remote has been updated since you began this sync.".yellow.bold
      puts "  Try running 'ezgit pull' again".yellow.bold
    elsif stat.eql?(:no_remote) || stat.eql?(:ahead)
      puts `git push -u #{remote_branch.sub('/', ' ')}`
      refresh_branches
    elsif stat.eql?(:headless)
      puts '  You cannot push unless you are on a branch.'.red.bold
    else
      #:up_to_date | :headless
    end
    info
  end


  private


  def prompt_for_y_n
    begin
      system("stty raw -echo")
      input = STDIN.getc
    ensure
      system("stty -raw echo")
    end
    out = input.to_s.downcase.eql?('y')
    puts input.to_s
    return out
  end


  def run_lambda_with_prompt(opts = nil)
    unless @git.no_prompt
      puts 'proceed(y/n)? '.bold
      return unless prompt_for_y_n
    end
    yield
  end

end