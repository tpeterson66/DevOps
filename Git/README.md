# Git Notes

## Rebase a forked branch

When you fork a repo but want to get the updates from the orginial source in your project:

```bash
# https://stackoverflow.com/questions/7244321/how-do-i-update-or-sync-a-forked-repository-on-github
# Add the remote, call it "upstream":

git remote add upstream https://github.com/whoever/whatever.git

# Fetch all the branches of that remote into remote-tracking branches

git fetch upstream

# Make sure that you're on your master branch:

git checkout master

# Rewrite your master branch so that any commits of yours that
# aren't already in upstream/master are replayed on top of that
# other branch:

git rebase upstream/master
```