EZGit
=====

(This project is currently under development)

 * http://github.com/ajjames/ezgit
 * http://rubygems.org/gems/ezgit

DESCRIPTION

  EZGit is a simple interface for working with git repositories.

USAGE
        ez [options] [commands]

  [commands] are:
        clean!  Deletes all changes and files to resemble only what is checked in.
        climb   Switch to the latest code on a given branch
        clone   Creates a copy of a repository.
        info    Shows files status and current branches.
        tree    Shows git tree history for the current branch
        update  Attempts to self-update from rubygems.org.

   [options] are:
  --dry-run, -n:   Forces all commands to be passive.
    --debug, -d:   Shows command level debug info.
  --version, -v:   Print version and exit
     --help, -h:   Show this message

ACKNOWLEDGEMENTS

  This project makes use of Trollop (Copyright 2007 William Morgan). An excellent light-weight command-line parser.