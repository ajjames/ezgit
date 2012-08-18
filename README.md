## EZGit
=====

(This project is currently under development)

 * http://github.com/ajjames/ezgit
 * http://rubygems.org/gems/ezgit


## DESCRIPTION

EZGit is a command-line interface based on Ruby. The **goal** of **EZGit** is to simplify the daily git tasks used in a multi-team enterprise development environment without the need to fully understand the full complex beauty of Git. With EZGit, committers with any level of Git knowledge can work in the repo with confidence and consistency.

EZGit abstracts away many Git concepts that are consistent sources of confusion. Concepts such as...
* _**Where do branches live? On my local machine or on the remote?**_ Who cares? EZGit handles it for you. 
* _**What's the difference between the working directory, the stage(or index), and the local repo?**_ I could spend hours explaining it to you, but if you don't really want to know, EZGit is here to make that stuff go away.

EZGit replaces git's complex and overloaded commands with simple, intentional, ruby-styled names. 

In future updates, EZGit will implement a branching strategy that has been honed and refined over the last two years by a large agile enterprise development shop. The concepts of merging (and rebasing) will be equally simplified so that you can concentrate on your code, and not on, "how the heck do I merge these changes?!"

Best of all, EZGit is still Git. So if you are a Git-Fu master, you can go back to using your favorite, obtuse Git commands at any time. They'll always be there waiting for you when you need to do the complex stuff.

If you try EZGit and find that it doesn't quite work for you, drop me a line and let me know why. I'm happy to look at other use cases and consider including them in future updates.

Cheers,

AJ


## INSTALLATION

To intall:

    gem install ezgit

EZGit changes a lot (especially during this development phase). To update your existing installs, you can use `gem update ezgit`, or you can use EZGit's self-update command:

    ez update


## HELP TEXT

Once installed, take a look at the help menu:

    ez -h


    EZGit is a simple interface for working with git repositories.

    Usage:
            ez [<options>] <commands>

      commands are:
        clean!  Wipes all untracked and ignored files.
        clean Wipes all untracked files, but allows ignored files to remain.
        clone Creates a copy of a repository.
        commit  Creates a commit for all current file changes.
        create  Create a new branch in the current state.
        delete! Completely delete a given branch.
        goto! Move to the location in the tree specified by a commit id. All changes will be lost.
        info  Shows files status and current branches.
        move  Switch and move changes to the given branch.
        pull  Pulls the latest changes from the remote.
        push  Pushes the current branch changes to the remote.
        reset!  Deletes changes in all tracked files. Untracked files will not be affected.
        switch! Abandon all changes and switch to the given branch.
        switch  Switch to the given branch if there are not changes.
        tree  Shows git tree history for the current branch
        update  Attempts to self-update from rubygems.org.

       options are:
      --dry-run-flag, -n:   Forces all commands to be passive.
             --debug, -d:   Shows command level debug info.
           --version, -v:   Print version and exit
              --help, -h:   Show this message


## EXAMPLE

```
~/git/test_repo > git init
Initialized empty Git repository in /Users/AJ/git/test_repo/.git/

~/git/test_repo > touch file1 file2 file3 .gitignore

~/git/test_repo > ez info
________________________________

REPOSITORY TREE(last 5 commits)
There is no history yet.

  BRANCHES:

  TO BE COMMITTED ON: master
     Add  .gitignore
     Add  file1
     Add  file2
     Add  file3

  SYNC STATUS:
  Your master branch does not yet exist on the remote.
  (Use 'ez pull' to update the remote.)
________________________________

~/git/test_repo > ez commit "initial commit"

[master (root-commit) e315617] initial commit
 0 files changed
 create mode 100644 .gitignore
 create mode 100644 file1
 create mode 100644 file2
 create mode 100644 file3

REPOSITORY TREE(last 5 commits)
* e315617 (0 seconds ago) AJ James initial commit (HEAD, master)

  TO BE COMMITTED ON: master
  No changes.

  SYNC STATUS:
  Your master branch does not yet exist on the remote.
  (Use 'ez pull' to update the remote.)
```


## ISSUES

To report issues at: 
https://github.com/ajjames/ezgit/issues


## ACKNOWLEDGEMENTS

  This project makes use of Trollop (Copyright 2007 William Morgan). An excellent light-weight command-line parser.