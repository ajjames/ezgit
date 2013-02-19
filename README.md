## EZGit
=====

(This project is currently under development)

 * http://github.com/ajjames/ezgit
 * http://rubygems.org/gems/ezgit


## DESCRIPTION

I like the Git source control system. It's truly awesome. And like the first time you disassembled your dad's VCR only to be stumped by all those gears and wires, Git probably gave you a bit of a brain-bending whirl when you first looked at it too. There is so much that Git can do, but only so little that you really need it to do. **EZGit** wants to help.

EZGit is a command-line interface written in Ruby and distributed as a gem. **The goal of EZGit** is to simplify your daily source control use cases without the need to fully gaze upon the complex beauty that is Git. With EZGit, committers with any level of Git knowledge can work in the repo with confidence and consistency.

EZGit abstracts away many Git concepts that are consistent sources of confusion. Concepts such as...
* _**Where do branches live? On my local machine or on the remote?**_ Who cares? EZGit handles it for you.
* _**What's the difference between the working directory, the stage(or index), and the local repo?**_ I could spend hours explaining it to you, but if you don't really want to know, EZGit is here to make those confusing thoughts go away.
* _**When would I need to do a 'git reset --hard', as opposed to '--soft' or '--mixed'?**_ If you're asking about staging files, stop thinking about that. You have better things to do. Just make your files and folders look the way you want and EZGit will take care of the rest.
* _**But I'm confused about the differences between git checkout, reset, revert, and other commands. Do some of these do more than one thing??**_  I know. I hear your pain. That's why EZGit replaces git's complex and overloaded commands with simple, clean, intentional, ruby-styled names. If any single git command has multiple, yet different _common_ uses, rest assured that EZGit provides an unique, easy-to-understand command for that task.

Ready to try, EZGit? Hold on, Cowboy. It ain't done yet. Go ahead and use it, but be sure to check back often for updates. In the future, EZGit will implement a branching strategy that has been honed and refined over the last two years by a large agile enterprise development shop. The concepts of merging (and rebasing) will be equally simplified so that you can concentrate on your code, and not on, "how the heck do I rebase and then --no-ff merge my changes?!" And, hey, while you're checking things out, drop an occasional line if you find a bug. That'd be nice.

Best of all, EZGit is still Git. So if you are a Git-Fu master, you can always go back to using your favorite overloaded Git commands at any time. They'll always be there waiting for you at those times when you absolutely need to cherry-pick your fixes from branchB onto branchA, interactively rebase & squash directly from branchC in your buddy's repo, and finally, ours-merge them into master ...or other stuff like that.

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

    ezgit -h


    EZGit is a simple interface for working with git repositories.

    Usage:
            ezgit [<options>] <commands>
                  - or -
            ez [<options>] <commands>
                  - or -
            eg [<options>] <commands>
                  - or -
            gt [<options>] <commands>

      commands are:
    	clean	Wipes untracked files unless they are marked as ignored(via .gitignore).
    	clone	Creates a copy of a repository.
    	commit	Creates a commit for all current file changes.
    	create	Create a new branch in the current state.
    	delete	Completely delete a given branch, both locally and on the remote.
    	goto	Move to the location in the tree specified by a commit id. All changes will be lost.
    	info	Shows files status and current branches.
    	move	Switch and move changes to the given branch.
    	pull	Pulls the latest changes from the remote.
    	push	Pushes the current branch changes to the remote.
    	reset	Deletes changes in all tracked files. Untracked files will not be affected.
    	scrub	Wipes untracked files including ignored files.
    	switch	Abandon all changes and switch to the given branch.
    	tree	Shows git tree history for the current branch
    	update	Attempts to self-update from rubygems.org.

       options are:
      --dry-run, -n:   Makes all commands passive.
        --force, -f:   Forces all prompting off. Use ! at end of command name to do the same.
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