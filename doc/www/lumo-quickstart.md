<!-- SPDX-License-Identifier: AGPL-3.0-only -->
<!-- SPDX-FileCopyrightText: 2020 The LumoSQL Authors, 2019 Oracle -->
<!-- SPDX-ArtifactOfProjectName: LumoSQL -->
<!-- SPDX-FileType: Documentation -->
<!-- SPDX-FileComment: Original by Dan Shearer, 2020 -->


Table of Contents
=================

   * [About LumoSQL](#about-lumosql)
   * [About the LumoSQL Project](#about-the-lumosql-project)
   * [LumoSQL Interfaces Are Almost the Same as SQLite](#lumosql-interfaces-are-almost-the-same-as-sqlite)
   * [Building and Installing LumoSQL](#building-and-installing-lumosql)
      * [Directory layout](#directory-layout)
      * [Linux/Unix](#linuxunix)
         * [Build environment](#build-environment)
         * [Using the Makefile tool](#using-the-makefile-tool)
   * [Running LumoSQL](#running-lumosql)
      * [Windows](#windows)
      * [Android](#android)
   * [Speed tests / benchmarking](#speed-tests--benchmarking)
   * [Which LMDB version?](#which-lmdb-version)
   * [References](#references)


About LumoSQL
=============

LumoSQL is a combination of two embedded data storage C language libraries:
[SQLite](https://sqlite.org) and [LMDB](https://github.com/LMDB/lmdb). LumoSQL
is an updated version of Howard Chu's 2013
[proof of concept](https://github.com/LMDB/sqlightning) combining the codebases.
Howard's LMDB library has become an ubiquitous replacement for
[bdb](https://sleepycat.com/) on the basis of performance, reliability, and
license so the 2013 claims of it greatly increasing the performance of SQLite
seemed credible. D Richard Hipp's SQLite is used in thousands of software
projects, and since three of them are Google's Android, Mozilla's Firefox and
Apple's iOS, an improved version of SQLite will benefit billions of people.

About the LumoSQL Project
=========================

LumoSQL was started in December 2019 by Dan Shearer, who did the original source
tree archaeology, patching and test builds. Keith Maxwell joined shortly after
and contributed version management to the Makefile and the benchmarking tools.

A main goal of the LumoSQL Project is to create and maintain an improved version of
SQLite without forking it, although there are other goals as well.

LumoSQL is supported by the [NLNet Foundation](https://nlnet.nl).

If you are interesting in contributing to LumoSQL please see [CONTRIBUTING](https://github.com/LumoSQL/LumoSQL/blob/master/CONTRIBUTING.md).



LumoSQL Interfaces Are Almost the Same as SQLite
================================================

Your interaction with the LumoSQL interface (commandline, PRAGMAs and API) is
almost identical to SQLite. You use the same APIs, the same command shell
environment, the same SQL statements, and the same PRAGMAs to work with the
database created by LumoSQL as you would if you were using SQLite.

To learn how to use SQLite, see the [SQLite Documentation](https://sqlite.org/docs.html).

That said, there are a few small differences between the two interfaces.

# Building and Installing LumoSQL

## Directory layout

In order to build LumoSQL and SQLite and to used different versions of the LMDB
library, we use the following directory layout:

```
.
├── bld-LMDB_?.?.?    Build artifacts for LumoSQL (src and src-lmdb)
├── bld-SQLite-?.?.?  Build artifacts for sqlite (src-sqlite)
├── LICENSES          License files, in line with https://reuse.software/spec/
├── lmdb-backend      C source code to use SQLite with an LMDB backend
├── src-lmdb          Clone of LMDB source code
├── src-sqlite        Clone of sqlite.org git mirror
└── tool              Cut down version of speedtest.tcl
```

## Linux/Unix


### Build environment

On Ubuntu 18.0.4 LTS, Debian Stable (buster), and on any reasonably recent
Debian or Ubuntu-derived distribution, you need only:

```sh
sudo apt install git build-essential tcl
sudo apt build-dep sqlite3
```

(`apt build-dep` requires `deb-src` lines uncommented in /etc/apt/sources.list).

On Fedora 30, and on any reasonably recent Fedora-derived distribution:

```sh
sudo dnf install --assumeyes \
  git make gcc ncurses-devel readline-devel glibc-devel autoconf tcl-devel
```

The maintainers test building LumoSQL on Debian, Fedora, Gentoo and Ubuntu.
Container images with the dependencies installed are available at
<https://quay.io/repository/keith_maxwell/lumosql-build> and the build steps are
in <https://github.com/maxwell-k/containers>.

### Using the Makefile tool

Start with a clone of this repository as the current directory:

    ```git clone https://github.com/LumoSQL/LumoSQL.git```

To build either (a) specific versions of SQLite or (b) sqlightning using
different versions of LMDB, use commands like those below changing the version
numbers to suit. A list of tested version numbers is in the table
[below](#which-lmdb-version).

```sh
make bld-SQLite-3.7.17
make bld-LMDB_0.9.9
```
# Running LumoSQL

libraries and a command line shell are built with the following names:

    ```lumosql```

    This is the command line shell. It operates identically to the SQLite sqlite3 shell.

    ```liblumosql```

    This is the library that provides the LumoSQL SQL interface. It is the equivalent of the SQLite libsqlite3 library.

## Windows

LumoSQL is not supported on Windows as of March 2020. We are aiming for May 2020. Want to help?

## Android

LumoSQL is not supported on Android as of March 2020. We are aiming for July 2020. Want to help?

# Speed tests / benchmarking

To benchmark a single binary takes approximately 4 minutes to complete depending
on hardware.

The instructions in this section explain how to benchmark four different
versions:

| V.  | SQLite | LMDB   | Repository | Report filename    |
| --- | ------ | ------ | ---------- | ------------------ |
| A.  | 3.7.17 | -      | SQLite     | SQLite-3.7.17.html |
| B.  | 3.30.1 | -      | SQLite     | SQLite-3.30.1.html |
| C.  | 3.7.17 | 0.9.9  | LumoSQL    | LMDB_0.9.9.html    |
| D.  | 3.7.17 | 0.9.16 | LumoSQL    | LMDB_0.9.16.html   |

To benchmark the four versions above use:

```sh
make benchmark
```

The "Repository" column means:

<dl>
<dt>SQLite</dt>
<dd>

<https://github.com/sqlite/sqlite>

</dd>
<dt>LumoSQL</dt>
<dd>

<https://github.com/LumoSQL/LumoSQL> (this repository)

</dd>
</dl>

# Which LMDB version?

`mc_orig` was removed and `mc_backup` added to `mdb.c` in
<https://github.com/LMDB/lmdb/commit/be47ca766713f55e5b3abd18120514fdad7d90f2>
first released in `LMDB_0.9.7` on 14 August 2013. `LMDB_0.9.8` was 9 September
2013 and `LMDB_0.9.9` was 24 October 2013.
<https://github.com/LMDB/sqlightning/commit/58b473f3d5570fca94b88398e0e4314208a077cd>
adapted `sqlightning` to this change on 12 September 2013. So first try
`LMDB_0.9.8`, but this fails with:
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
| LMDB_0.9.19 | 2016-12-28 | ✓        | ✗          |     6 |  684 | 447 |
| LMDB_0.9.21 | 2017-06-01 | ✓        | ✗          |    23 |   81 |  50 |
| LMDB_0.9.22 | 2018-03-22 | ✓        | ✗          |    23 |   74 |  58 |
| LMDB_0.9.23 | 2018-12-19 | ✓        | ✗          |     4 |   52 |   9 |
| LMDB_0.9.24 | 2019-07-19 | ✓        | ✗          |     6 |   16 |  11 |

The [GitHub LMDB mirror](https://github.com/LMDB/lmdb/releases) does not include
a release `LMDB_0.9.20`, releases before 0.9.8 are not shown.

<dl>
<dt>Compiles</dt>
<dd>✓ means the process documented above completes successfully.</dd>
<dt>Speed test<dt>
<dd>✓ means the cut down version of speed test passes in `./tool/speedtest.tcl`
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
