# CorsixTH Contributing Guidelines #

## Tell other devs what you are working on! ##

When you start working on a fix/enhancement for an open issue always post a
comment in this issue's discussion to tell other devs that you have started
working on it so that they won't waste any of their free time by working on
their own fix/enhancement for it.

If there isn't an open issue for a bug fix/enhancement you want to work on
please check that one wasn't closed by a previous developer who didn't finish
their work, which you could finish.

And if there is no existing issue the bug fix or feature you plan to contribute
open a new issue for it and tell other devs here that your going to/have
started working on it.

**If you have an idea for an enhancement that does not have a discussion, make
a *Feature Request* first to discuss its desirability. This helps make sure
your development time is a worthy endeavour.**

## Enhancement/Suggestions ##

To suggest an enhancement, open a new [issue](https://github.com/CorsixTH/CorsixTH/issues/new/choose) and click the *Feature Request*
button. It will provide all the information needed to evaluate the
suggestion or enhancement.

![image](https://user-images.githubusercontent.com/20030128/123638352-fc609400-d816-11eb-88ad-11030e041fc4.png)


## Clean-Room Development ##
  
CorsixTH uses clean-room principles when reimplementing behaviour from Theme
Hospital.

You can use the original game, including through DOSBox or another compatible
environment, to observe its visible and audible behaviour and compare it with
CorsixTH.

You must not:
- disassemble or decompile the original game;
- inspect or modify its executable code;
- inspect process memory to discover implementation details;
- derive behaviour from machine code or internal data structures; or
- reproduce original source code or other non-public implementation details.

You can:
- observe the original game's visible and audible behaviour;
- provide inputs and record how the game responds;
- compare those observations with CorsixTH;
- use existing CorsixTH code, tests, issues, and documentation;
- use existing Theme Hospital documentation and gemaplay content such as videos
- investigate and debug CorsixTH itself; and
- work with original game data files where needed to support data used by CorsixTH.

If reproducing a behaviour would require examining how the original executable
works, please consult the project maintainers before continuing.

## Pull Requests (PRs) ##

When submitting a pull request submit only a description of the major changes
of your contribution.\
Do not include unnecessasry information in your description, such as build or
test results.

If the pull request relates to any existing issues,
link those issues to the description by referencing them with a `Fixes #` followed
by the issue number (one `Fixes #` per line per issue).\
The pull request form provides a default layout to help you fill out this information.

### Pull Requests and Reviews ###
  
Submitting or managing a pull request, making review decisions, and
communicating with reviewers are your responsibility.

If you use AI tools, they must not submit, manage, approve, or merge pull requests,
communicate on the your behalf, or draft or make review decisions. You must decide
what to say and write yourself.

AI tools can help you understand review feedback, find the relevant code or
behaviour, consider possible technical changes, and identify points to
address. You can always use an AI tool to translate something you have written
into English.

**Failure to follow these practices may result in your pull request being rejected**

### Pull Request Statuses ###
CorsixTH encourages using the following labels inside your Pull Request's title
to denote its current progress. Unlabelled pull request will be considered
*Ready* and may be merged without warning.
| Label | Description |
| ----- | ----------- |
| **[WIP]** | Work in Progress |
| **[RFC]** | (Optional stage) Request for Comments (aka Ready for Review) |
| ***\<none>*** | Ready |

Please make sure you label and update your Pull Request accordingly.
You can also submit a **Draft Pull Request** as an alternative to the
**[WIP]** label.

### CorsixTH Developers: Configuring Pull Requests ###
All pull requests in CorsixTH must have an appropriate PR label before merging to
master. This ensures it goes into the current project. Those in Draft/[WIP] do not
need a label until past that stage.

Available labels are:
| Label | Description |
| ----- | ----------- |
| **PR:Bugfix** | Code that fixes something broken. |
| **PR:DevTools/Repo** | Code that mainly serves the CorsixTH repository, developer assets, or compilation and CI tools. |
| **PR:Feature** | Implementation of something brand new to CorsixTH that did not exist before. Includes creating a missing feature of TH. |
| **PR:Improvement** | Improvements to a feature or function that already exists. This includes changes to achieve closer matching behaviour with TH.
| **PR:Refactor** | Altering the structure of existing code without necessarily changing desired functionality. |
| **PR:Translation** | Contributions to CorsixTH's translations. |

There is also the label `PR:need-rebase`, that developers should apply to any pull
request that requires syncing/rebase with master before merge. It can be removed
after a rebase.

## CONTRIBUTING CODE: ##

### Codestyle ###
**Important!**\
Ensure you have read our [Coding Conventions](https://github.com/CorsixTH/CorsixTH/wiki/Coding-Conventions)
before starting your work. CorsixTH may use styles different to your previous experience with ``Lua``
and ``C++``. The [Wiki](https://github.com/CorsixTH/CorsixTH/wiki/) also contains other useful information
that could be beneficial before contributing code.

### AI-Assisted Contributions ###
  
AI tools can be used to help develop, review, document, test, or refactor
CorsixTH, but must not be used to generate creative assets.

Any AI-assisted work is still your responsibility. Make sure you understand and
are able to explain the changes you submit.

Before submitting your changes, check that any AI-assisted work follows the
project conventions and standards. Additionally, check the
tool's assumptions, the effect of the change, the validation carried out, and
any known limitations.

Generated tests or successful local checks do not on their own prove that a
change is correct or suitable for inclusion.


### Development Workflow ###
*NB: If you're using GitHub Desktop ignore the git specific commands and follow
guidance from [GitHub Docs](https://docs.github.com/en/desktop/installing-and-configuring-github-desktop/overview/getting-started-with-github-desktop)*\
**First Time**
1. Ensure you have a GitHub account (https://github.com/signup/free)
2. Fork CorsixTH\CorsixTH (https://github.com/CorsixTH/CorsixTH/fork)
3. Ensure you have a git client. ([GitHub Desktop](http://desktop.github.com)
[Interactive] | [Git](https://git-scm.com/downloads) [Shell])
4. Fork the CorsixTH/CorsixtTH project to your account, the CorsixtTH/CorsixtTH
project page has a button for this.
5. Clone your fork to your computer
	- ``git clone https://github.com/mygithubuser/CorsixTH.git``
6. Add upstream remote
	- ``git remote add upstream https://github.com/CorsixTH/CorsixTH.git``

**Every Time**
1. Sync your master branch with the CorisxTH repository's master branch
- ``git checkout master``
- ``git fetch upstream``
- ``git merge --ff-only upstream/master``
2. Make sure no one is already working on the issue you want to work on.
3. Tell other developers that you've started/will start working on this issue
by posting a comment in its existing issue discussion or if there's no existing
discussion for it then please open a new issue discussion for it and tell other
devs here that your working on it.
4. Create feature branch from your master
	- ``git branch myfeature master``
5. Checkout your feature branch
	- ``git checkout myfeature``
6. Make your changes
7. Unittest continuously, see README.txt in CorsixTH/Luatest for more info
8. Review, add, and commit your changes.\
Note: ``C++`` code must be formatted using ``clang-format`` before it will be accepted
	- ``git diff`` | See your changes.
	- ``git diff --check`` | Check there's no white space.
	- ``git add`` | do this for each file
	- ``git commit`` | Write an informative commit message and save.
9. Push your changes to your fork
	- ``git push origin myfeature``
9. Create a Pull Request -- GitHub will pick up your latest branch committed to
automatically when accessing CorsixTH/CorsixTH.

The developers will review and report any changes needed to your Pull Request
so it could be accepted.

#### Notes ####
##### Multiple commits: #####
If your pull request can not be summarised in a single sentence, break it into smaller steps
and do a separate commit for every independent operation (e.g. one sentence per commit is a
good measure). This means doing step 10 several times as you go. You still only need to do
one pull request at the end.

##### Syncing with Upstream: #####
If it takes a long time between when you start your feature and when you finish
there might be other important changes other people are making to CorsixTH. To
ensure your pull request operates correctly within the latest changes:
- Commit your work to the feature branch
- ``git checkout master``
- ``git fetch upstream``
- ``git merge --ff-only master``
- ``git checkout myfeature`` | switch back to your feature branch to continue
working on it

*NB: GitHub Desktop users need to conduct fetch upstream from your branch on
github.com and rebase from GitHub Desktop after*\
This downloads all the changes from CorsixTH/CorsixTH since you
started, and moves your commits on top of them. If there are
conflicts, for example if someone else changed the same line in the same file
that you did you will be asked to resolve those conflicts.

If you follow these guidelines then you should be well on your way to producing
good pull requests.

If you need more help get in touch at our [Discord Server](https://discord.gg/Mxeztvh) or via [Matrix](https://matrix.to/#/#corsixth-general:matrix.org).
