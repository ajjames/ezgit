require 'open3'

$commands.all << {
    name: 'climb',
    help: 'Switch to the latest code on a given branch',
    usage: 'ez climb [branch_name]',
    options: [
        [:verbose, 'Show all the nitty-gritty details', short: '-v']
    ],
    action: lambda do |opts, args|
      #stdin, stdout, stderr = Open3.popen3('git checkout')
    end
}