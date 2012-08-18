EZGit
=====

(This project is currently under development)

 * http://github.com/ajjames/ezgit
 * http://rubygems.org/gems/ezgit

DESCRIPTION

    EZGit is a simple interface for working with git repositories.

    Usage:
            ez [<options>] <commands>

      commands are:
        clean!	Wipes all untracked and ignored files.
        clean	Wipes all untracked files, but allows ignored files to remain.
        clone	Creates a copy of a repository.
        commit	Creates a commit for all current file changes.
        create	Create a new branch in the current state.
        delete!	Completely delete a given branch.
        goto!	Move to the location in the tree specified by a commit id. All changes will be lost.
        info	Shows files status and current branches.
        move	Switch and move changes to the given branch.
        pull	Pulls the latest changes from the remote.
        push	Pushes the current branch changes to the remote.
        reset!	Deletes changes in all tracked files. Untracked files will not be affected.
        switch!	Abandon all changes and switch to the given branch.
        switch	Switch to the given branch if there are not changes.
        tree	Shows git tree history for the current branch
        update	Attempts to self-update from rubygems.org.

       options are:
      --dry-run-flag, -n:   Forces all commands to be passive.
             --debug, -d:   Shows command level debug info.
           --version, -v:   Print version and exit
              --help, -h:   Show this message


ACKNOWLEDGEMENTS

  This project makes use of Trollop (Copyright 2007 William Morgan). An excellent light-weight command-line parser.