# CorisxTH Contributing Guidelines #

## Tell other devs what you are working on! ##

When you start working on a fix/enhancement for an open issue always post a comment in this issue's discussion to tell other devs that you have started working on it so that they won't waste any of their free time by working on their own fix/enhancement for it.

If there isn't an open issue for a bug fix/enhancement you want to work on please check that one wasn't closed by a previous developer who didn't finish their work, which you could finish.

And if there is no existing issue the bug fix or feature you plan to contribute open a new issue for it and tell other devs here that your going to/have started working on it.

**If you have an idea for an enhancement that does not have a discussion, make a *Feature Request* first to discuss its desirability.  This helps make sure your development time is a worthy endeavour.**

## Enhancement/Suggestions ##

If you want to make a suggestion, please use the *Feature Request* option when making a new issue. It will provide all the information needed to evaluate the suggestion or enhancement.\
![image](https://user-images.githubusercontent.com/20030128/123638352-fc609400-d816-11eb-88ad-11030e041fc4.png)


## Pull Requests ##

When providing a pull request ensure the description field describes the major changes from the request. If your pull request relates to any existing issues, include those issues in the description. The pull request provides a default layout to help you fill out this information.

#### Pull Request Statuses ####
CorsixTH encourages using the following labels inside your Pull Request's title to denote its current progress. Unlabelled pull request will be considered *Ready* and may be merged without warning.
| Label | Description |
| ----- | ----------- |
| **[WIP]** | Work in Progress |
| **[RFC]** | (Optional stage) Request for Comments (aka Ready for Review) |
| ***\<none>*** | Ready |

Please make sure you label and update your Pull Request accordingly. Alternatively, you can submit a **Draft Pull Request** as an alternative to the **[WIP]** label.


#### CONTRIBUTING CODE: ####

*NB: If you're using GitHub Desktop ignore the git specific commands and follow guidance from [GitHub Docs](https://docs.github.com/en/desktop/installing-and-configuring-github-desktop/overview/getting-started-with-github-desktop)*\
**First Time**
1. Ensure you have a GitHub account (https://github.com/signup/free)
2. Fork CorsixTH\CorsixTH (https://github.com/CorsixTH/CorsixTH/fork)
3. Ensure you have a git client.  ([GitHub Desktop](http://desktop.github.com) [Interactive] | [Git](https://git-scm.com/downloads) [Shell])
4. Fork the CorsixTH/CorsixtTH project to your account, the CorsixtTH/CorsixtTH project page has a button for this.
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
3. Tell other developers that you've started/will start working on this issue by posting a comment in its existing issue discussion or if there's no existing discussion for it then please open a new issue discussion for it and tell other devs here that your working on it.
4. Create feature branch from your master
	- ``git branch myfeature master``
5. Checkout your feature branch
	- ``git checkout myfeature``
6. Make your changes
7. Unittest continuously, see README.txt in CorsixTH/Luatest for more info
8. Review, add, and commit your changes
	- ``git diff`` | See your changes.
	- ``git diff --check`` | Check there's no white space.
	- ``git add`` | do this for each file
	- ``git commit`` | Write an informative commit message and save.
9. Push your changes to your fork
	- ``git push origin myfeature``
9. Create a Pull Request -- GitHub will pick up your latest branch committed to automatically when accessing CorsixTH/CorsixTH.

The developers will review and report any changes needed to your Pull Request so it could be accepted.

#### Notes ####
##### Multiple commits: #####
If your feature is very big, break it into smaller steps and do a separate commit for every independent operation.  This means doing step 10 several times as you go. You still only need to do one pull request at the end.

##### Syncing with Upstream: #####
If it takes a long time between when you start your feature and when you finish there might be other important changes other people are making to CorsixTH.  It is a good idea to make sure your code will still operate correctly with the latest changes.  To do this:
- Commit your work to the feature branch
- ``git checkout master``
- ``git fetch upstream``
- ``git merge --ff-only master``
- ``git checkout myfeature`` | switch back to your feature branch to continue working on it

*NB: GitHub Desktop users need to conduct fetch upstream from your branch on github.com and rebase from GitHub Desktop after*\
What this does is downloads all the changes from CorsixTH/CorsixTH since you started, and pretends that all your changes were made after them.  If there are conflicts, for example if someone else changed the same line in the same file that you did you will be asked to resolve those conflicts.

If you follow these guidelines then you should be well on your way to producing good pull requests.

If you need more help get in touch at our [Discord Server](https://discord.gg/Mxeztvh) or via [Matrix](https://matrix.to/#/#corsixth-general:matrix.org).
