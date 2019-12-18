<!-- SPDX-License-Identifier: Apache-2.0 -->
<!-- SPDX-FileCopyrightText: 2019 The LumoSQL Authors -->

# LumoSQL

## About LumoSQL

LumoSQL is a combination of two embedded data storage C language libraries:
[SQLite](https://sqlite.org) and [LMDB](https://github.com/LMDB/lmdb). LumoSQL
is an updated version of Howard Chu's 2013
[proof of concept](https://github.com/LMDB/sqlightning) combining the codebases.
Howard's LMDB library has become ubiquitous on the basis of performance and
reliability, so the 2013 claims of it greatly increasing the performance of
SQLite seem credible. D Richard Hipp's SQLite is relied on by many millions of
people on a daily basis (every Android and Firefox user, as just two projects of
the thousands that use SQLite) so an improved version of SQLite would benefit
billions of people.

The original code changes `btree.c` in SQLite 3.7.17 to use LMDB 0.9.9 . It
takes some work to replicate the original results because not only has much
changed since, but as a proof of concept there was no project established to
package code or make it accessible. LumoSQL revives the original code and shows
how it is still relevant in 2019. The premise seems sound.

## About the LumoSQL Project

LumoSQL was started in December 2019 by Dan Shearer, who did the original source
tree archaeology. Keith Maxwell did the detailed initial work of integration,
test and verification to produce the Makefile tool.

The goal of the LumoSQL Project is to create and maintain an improved version of
SQLite.

## The LumoSQL Makefile tool

LumoSQL provides a Makefile which:

- Re-creates the 2013 proof of concept tree
- Creates new trees using updated code until the 2013 work starts breaking
- Allows the 2013 speed tests to be easily replicated on the original and new
  combined codebases
- Allows a testing matrix of versions and results

In the process, we noticed things that need to be fixed:

- Regressions. Some SQLite functionality doesn't work out of the box with the
  2013 code, even some basic things like ".schema"
- Test suite. Even the speed test portion of the SQLite test suite only partly
  works.
- Close coupling in SQLite. Higher levels of SQLite makes assumptions about how
  the btree code is implemented, e.g. knowledge about page sizes.
- Close coupling in the port, e.g. the 2013 `btree.c` `#includes` LMDB's `mdb.c`
  (not `mdb.h`) and directly modifies the internal LMDB struct `MDB_page`.
- Bit-rot. The upstream trees stopped working together in 2015.

* Regressions, test failures, opportunities and more are tracked as
  [issues](https://github.com/LumoSQL/LumoSQL/issues)
* Short term planning and progress reporting is tracked on a
  [project board](https://github.com/LumoSQL/LumoSQL/projects)

## Branches

- The `master` branch is the currently completed work, this should build on
  supported systems and pass the relevant tests (see below). This branch was
  previously called `benchmarking`.
- Development typically happens in branches beginning with `feature/`

The `master` branch includes a cut down version of SQLite's
`tools/speedtest.tcl` that passes for the 2013 sqlightning proof of concept. It
has been cut down to remove tests that did not pass with that code but is
nevertheless useful and valid:

```sh
git diff tool/speedtest.tcl src/tool/speedtest.tcl
```

# Compiling SQLite and sqlightning

## Directory layout

In order to build LumoSQL and SQLite and to used different versions of the LMDB
library, we use the following directory layout:

```
.
├── bld-LMDB_?.?.?    Build artifacts for LumoSQL (src and src-lmdb)
├── bld-SQLite-?.?.?  Build artifacts for sqlite (src-sqlite)
├── LICENSES          License files, in line with https://reuse.software/spec/
├── src               C source code
├── src-lmdb          Clone of LMDB source code
├── src-sqlite        Clone of sqlite.org git mirror
└── tool              Cut down version of speedtest.tcl
```

## Build environment

On Ubuntu 18.0.4 LTS, and on any reasonably recent Debian or Ubuntu-derived
distribution, you need only:

```sh
sudo apt install git build-essential
sudo apt build-dep sqlite3
```

(`apt build-dep` requires `deb-src` lines uncommented in /etc/apt/sources.list).

On Fedora 30, and on any reasonably recent Fedora-derived distribution:

```sh
sudo dnf install --assumeyes \
  git make gcc ncurses-devel readline-devel glibc-devel autoconf tcl-devel
```

The following steps have been tested on Fedora 30 and Ubuntu 18.04 LTS (via the
`container` target in the [Makefile](/Makefile)).

## Using the Makefile tool

Start with a clone of this repository as the current directory.

To build either (a) specific versions of SQLite or (b) sqlightning using
different versions of LMDB, use commands like those below changing the version
numbers to suit. A list of tested version numbers is in the table
[below](#which-lmdb-version).

```sh
make bld-SQLite-3.7.17
make bld-LMDB_0.9.9
```

# Speed tests / benchmarking

To benchmark a single binary takes approximately 4 minutes to complete depending
on hardware.

The instructions in this section explain how to benchmark four different
versions:

| V.  | SQLite | LMDB   | Repository  | Name          |
| --- | ------ | ------ | ----------- | ------------- |
| A.  | 3.7.17 | -      | SQLite      | SQLite-3.7.17 |
| B.  | 3.30.1 | -      | SQLite      | SQLite-3.30.1 |
| C.  | 3.7.17 | 0.9.9  | sqlightning | LMDB_0.9.9    |
| D.  | 3.7.17 | 0.9.16 | sqlightning | LMDB_0.9.16   |

To benchmark the four versions above use:

```sh
make benchmark
```

# Which LMDB version?

`mc_orig` was removed and `mc_backup` added to `mdb.c` in
<https://github.com/LMDB/lmdb/commit/be47ca766713f55e5b3abd18120514fdad7d90f2>
first released in `LMDB_0.9.7` on 14 August 2013. `LMDB_0.9.8` was 9 September
2013 and `LMDB_0.9.9` was 24 October 2013.
`58b473f3d5570fca94b88398e0e4314208a077cd` made adapted `sqlightning` to this
change on 12 September 2013. So first try `LMDB_0.9.8`, but this fails with:
`sqlite3.c:38156:2: error: unknown type name ‘mdb_hash_t’`.

Likely need
[this commit](https://github.com/LMDB/lmdb/commit/01dfb2083dd690707a062cabb03801bfad1a6859),
found through a
[GitHub comparison](https://github.com/LMDB/lmdb/compare/LMDB_0.9.8...LMDB_0.9.9).

| Tag         | Date       | Compiles | Speed test | Files | Ins. | De. |
| ----------- | ---------- | -------- | ---------- | ----: | ---: | --: |
| LMDB_0.9.8  | 2013-09-09 | ✗        | -          |     - |    - |   - |
| LMDB_0.9.9  | 2013-10-24 | ✓        | ✓          |     6 |  577 | 540 |
| LMDB_0.9.10 | 2013-11-12 | ✓        | ✓          |     5 |  216 | 121 |
| LMDB_0.9.11 | 2014-01-15 | ✓        | ✓          |     6 |  443 | 273 |
| LMDB_0.9.12 | 2014-06-18 | ✓        | ✓          |    12 |  516 | 333 |
| LMDB_0.9.13 | 2014-06-18 | ✓        | ✓          |     3 |   28 |  22 |
| LMDB_0.9.14 | 2014-09-20 | ✓        | ✓          |    23 | 2331 | 441 |
| LMDB_0.9.15 | 2015-06-19 | ✓        | ✓          |    24 |  388 | 187 |
| LMDB_0.9.16 | 2015-08-14 | ✓        | ✓          |     5 |   44 |  19 |
| LMDB_0.9.17 | 2015-11-30 | ✓        | ✗          |    10 | 1072 | 565 |
| LMDB_0.9.18 | 2016-02-05 | ✓        | ✗          |    24 |  303 |  57 |
| LMDB_0.9.19 | 2016-12-28 | ✗        | -          |     6 |  684 | 447 |
| LMDB_0.9.21 | 2017-06-01 | ✗        | -          |    23 |   81 |  50 |
| LMDB_0.9.22 | 2018-03-22 | ✗        | -          |    23 |   74 |  58 |
| LMDB_0.9.23 | 2018-12-19 | ✗        | -          |     4 |   52 |   9 |
| LMDB_0.9.24 | 2019-07-19 | ✗        | -          |     6 |   16 |  11 |

The [GitHub LMDB mirror](https://github.com/LMDB/lmdb/releases) does not include
a release `LMDB_0.9.20`, releases before 0.9.8 are not shown.

<dl>
<dt>Compiles</dt>
<dd>✓ means the process documented above completes successfully.</dd>
<dt>Speed test<dt>
<dd>✓ means the cut down version of speed test passes in benchmarking branch
passes.</dd>
<dt>Files</dt>
<dd>The number of files changed between the previous release and this one, as
reported by <code>git diff --shortstat</code>.</dd>
<dt>Ins.</dt>
<dd>The number of insertions as for the "Files" column.</dd>
<dt>De.</dt>
<dd>The number of deletions as for the "Files" column.</dd>
</dl>

A **?** means that this has not been tested, and a **-** means that it is not
applicable at present.

# References

- The
  [Fedora Spec file for "sqlite3"](https://apps.fedoraproject.org/packages/sqlite/sources/)
  lists dependencies.
- The [documentation](https://sqlite.org/whynotgit.html#getthecode) linking to
  the [official SQLite GitHub mirror](https://github.com/sqlite/sqlite)
- ["sqlightning" repository](https://github.com/LMDB/sqlightning)
- Early benchmarking by Howard Chu of <https://pastebin.com/B5SfEieL> of 3.7.17
- Benchmarking
  <https://github.com/google/leveldb/blob/master/benchmarks/db_bench_sqlite3.cc>
