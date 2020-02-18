# How LumoSQL uses git and GitHub

We want to be welcoming to new LumoSQL contributors regardless of their
experience with git and GitHub. We have developed a lightweight workflow process
with a few automated checks.

We welcome contributions from the community and at the moment
[Dan](https://github.com/danshearer) and [Keith](https://github.com/maxwell-k/)
are the two people who are reviewing pull requests.

## New authors

If you are contributing code or docs to LumoSQL for the first time then start
here. The default workflow involves [working with forks] on GitHub. If this is
difficult for you, please [raise an issue] or otherwise contact us and we will
find another way to collaborate. GitHub's [help on pull requests] is
comprehensive. And if you're a command line kind of person, you can do what you
need from there.

This is the pull request process:

1. Start with a clone of this repository on your local system; make some changes
   and decide you are ready to share.

   To help with that decision, you may choose to test the changes in a clean
   environment that's ready to go for LumoSQL. We provide some Linux container
   images which include the dependencies for LumoSQL at
   <https://quay.io/repository/keith_maxwell/lumosql-build>.

2. Fork the repository under your own GitHub account.

3. Commit your changes locally using git and push them to a new branch in your
   own fork on GitHub.

4. [Create a pull request]

   Authors who prefer to work on the command line may choose to use
   [hub](https://github.com/github/hub) to submit pull requests. In February
   2020, GitHub launched a [command line interface](https://cli.github.com). It
   is [in beta](https://github.com/cli/cli/#gh---the-github-cli-tool) and we're
   trying it out.

   This project has a preference for keeping the git history clean and easy to
   follow. Version control is important to the project as we are integrating
   several software components. We use some automated checks which are explained
   under "Automation" below.

5. Request a review or mention a maintainer by name

   The project's maintainers plan to actively monitor pull requests and hope to
   respond promptly. Requesting a review or mentioning them in comments may help
   draw attention to your changes.

6. Respond to comments and work with the maintainers to get your changes merged.

What if you'd like to share your enthusiasm for some changes with us but aren't
sure they are ready to be reviewed or merged into the project yet? You can use a
[draft pull request] , which is very similar to the pull request process above.

If you have contributed before and been given privileged access to this
repository the following section, "Existing authors", explains the slightly
modified guidelines.

[help on pull requests]:
  https://help.github.com/en/github/collaborating-with-issues-and-pull-requests
[draft pull request]:
  https://help.github.com/en/github/collaborating-with-issues-and-pull-requests/about-pull-requests#draft-pull-requests
[working with forks]:
  https://help.github.com/en/github/collaborating-with-issues-and-pull-requests/working-with-forks
[create a pull request]:
  https://help.github.com/en/github/collaborating-with-issues-and-pull-requests/creating-a-pull-request
[raise an issue]:
  https://help.github.com/en/github/managing-your-work-on-github/creating-an-issue

## Existing authors

If you have been given privileged access to this GitHub repository (because you
have successfully contributed before and you want to make it a habit, and
thankyou very much)... you do not need to work in your own separate fork. You
can instead work in a branch within this repository. As a project we have
adopted some conventions for naming our branches:

- `feature/example-short-description` if you are working on a new feature
- `bug/X` if you are working on issue number X from the tracker, otherwise if
  you are working on some other bug: `bug/example-short-description`
- `chore/example-short-description` if you are working on something else

Changes to content in `doc/` can be made directly on `master`.

## Reviewers

A pull request needs one approval, through the GitHub user interface, including
for existing authors. There is one exception: pull requests that only change
content in the `doc/` directory can be merged without review to those who have
been given commit access.

## Automation

The git history for the project is important. We try to avoid merging commits
before they are ready, that's why we have a review step. You'll see we like to
engage via the issue tracker and in other ways, and we have the draft pull
request process.

For example: if an author uses `git commit --fixup` we have a check that should
prevent merging before the author runs the related `git rebase --autosquash`.

At present we are trialling https://bors.tech as a way of running additional
checks before merging a pull request. This is in part an attempt to maintain a
semi-linear history. You don't need to know anything about it, only that if
everything works the way we hope then we will get alerted if someone looks like
they are about to accidentally cause a git history problem.
