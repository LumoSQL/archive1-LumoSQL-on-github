# Contributing

First, thank you for reading this and taking the time to contribute.

---

## Quick start

### How do I report a bug?

Bugs are tracked as [GitHub issues](https://github.com/LumoSQL/LumoSQL/issues).

### How do I suggest an enhancement?

You have two options:

1. Follow the steps below under "How do I submit a patch?" or
2. Submit a request as a
   [GitHub issue](https://github.com/LumoSQL/LumoSQL/issues)

### How do I submit a patch?

Please fork the repository on GitHub and submit a pull request. We go into more
detail about this process or the alternatives in our documentation:
[How LumoSQL uses git and GitHub](doc/using-git-and-github.md).

---

## Testing

We provide a [set of Linux container images] for testing LumoSQL under different
Linux distributions. We also run a small set of
[benchmarks](./tool/speedtest.tcl) before merging code in order to avoid
performance regressions.

[set of linux container images]:
  https://quay.io/repository/keith_maxwell/lumosql-build

## Style guides

For more details please see
[How LumoSQL uses git and GitHub](doc/using-git-and-github.md) in our
documentation.

### Commit messages

- Use the present tense ("Add feature" not "Added feature")
- Use the imperative mood ("Move cursor to..." not "Moves cursor to...")
- Limit the first line to 72 characters or less
- Reference issues and pull requests liberally after the first line
- Please rebase as required, we have CI block merging commits that which start
  with `fixup!` or `squash!`

### Pull requests

We are maintaining a semi-linear git history; we have automation and checks to
help with this. The maintainers will help as a part of the review step.

## Linters

A lot of our markdown is formatted with <https://prettier.io>; the JavaScript
code in `benchmarking/` uses ESLint and prettier.
