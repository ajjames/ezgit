$commands.all << {
    name: 'create',
    help: 'Create a new branch in the current state.',
    usage: 'ez create! <branch_name>',
    options: [],
    action: lambda do |opts, args|
      $commands.git.create(opts,args)
    end
}