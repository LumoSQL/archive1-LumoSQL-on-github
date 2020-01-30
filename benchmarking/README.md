# Benchmarking

## Quick start

The steps below publish the benchmarking results on GitHub pages:

```sh
export DATA=../../../../data     # or wherever you keep it
npm run dev                      # check everything looks OK
test -d gh-pages || git worktree add gh-pages gh-pages
npm run gh-pages
cd gh-pages
python3 -m http.server           # check it looks good or another http server
git commit
git push
unset DATA                       # otherwise tests fail
```

## Terminology

1. Several runs make up a data **set**
2. A **run** includes separate reports on different versions, it can be
   represented as a directory
3. A **report** shows the results of different tests for a single version, it
   can be represented as an HTML file
4. This benchmarking compares different **versions** for example upstream SQLite
   3.7.17 is a version
5. Comparisons are made across different **tests**, tests typically have a name
   and a value

## Design choices

This benchmarking project:

- uses ES Modules where possible
- avoids a module bundler like "rollup" as much as possible for simplicity
- has 100% test coverage for `src/utils/`
- formats everything with https://prettier.io
- checks JavaScript and Svelte code with https://eslint.org

## Prerequisites

- Node JS >= 12, for ES Modules support

## Tests

This project uses the [Mocha](https://mochajs.org) test framework. Mocha's
support for ES Modules with Node is a
[work in progress](https://github.com/mochajs/mocha/pull/4038). The version of
mocha specified in `package.json` is an experimental release with support for ES
Modules.
