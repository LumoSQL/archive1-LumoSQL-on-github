# Introduction

- Regressions, test failures, opportunities and more are tracked as
  [issues](https://github.com/maxwell-k/201912-sqlightning/issues)
- Short term planning and progress reporting is tracked on a
  [project board](https://github.com/maxwell-k/201912-sqlightning/projects/1)

## Branches

<dl>
<dt>

`benchmarking`

</dt>
<dd>this README and simplified benchmarking code (default)</dd>
<dt>

`results`

</dt>
<dd>benchmarking results</dd>
<dt>

[`mdb`](https://github.com/maxwell-k/201912-sqlightning/tree/mdb)

</dt>
<dd>the sqlightning code base</dd>
<dt>

[`orig`](https://github.com/maxwell-k/201912-sqlightning/tree/orig)

</dt>
<dd>for tracking SQLite versions</dd>
</dl>

The default branch includes a cut down `tools/speedtest.tcl` that can be used
for comparisons across LMDB backed and other SQLite versions, to view the
differences:

```sh
git diff orig:tool/speedtest.tcl benchmarking:tool/speedtest.tcl
```

# Compiling SQLite and sqlightning

## Overview

As a result of the steps below the following directory structure will be
created:

```
.
├── bld-mdb       Build artifacts for sqlightning
├── bld-orig      Build artifacts for sqlite from sqlightning repository
├── bld-sqlite    Build artifacts for sqlite from sqlite.org mirror
├── src-lmdb      Clone of LMDB source code
├── src-mdb       Checkout of the mdb branch of this repository
├── src-orig      Checkout of the orig branch of this repository
└── src-sqlite    Clone of sqlite.org git mirror
```

## Dependencies

- Either [toolbox](https://github.com/containers/toolbox) to develop in pet
  containers or a Fedora 30 installation
- SSH key for GitHub access

## Manual steps

1. Create a suitable directory:

   ```sh
   sudo mkdir /var/srv/lumosql &&
   sudo chown "$LOGNAME:$LOGNAME" /var/srv/lumosql
   ```

2. Create and enter a pet container, if using toolbox:

   ```sh
   toolbox create --container lumosql --image fedora-toolbox:30 &&
   toolbox enter --container lumosql
   ```

3. Install necessary tools to compile `sqlite` based on the Fedora spec file:

   ```sh
   sudo dnf install --assumeyes \
     make gcc ncurses-devel readline-devel glibc-devel autoconf tcl-devel
   ```

4. To build either (a) specific versions of SQLite or (b) sqlightning using
   different versions of LMDB, use commands like those below:

   ```sh
   make bld-sqlite-3.7.17
   make bld-LMDB_0.9.9
   ```

# Speed tests / benchmarking

Prerequisites: steps above all complete successfully.

The instructions in this section explain how to benchmark four different
versions:

| V.  | SQLite | LMDB   | Repository  | Name          |
| --- | ------ | ------ | ----------- | ------------- |
| A.  | 3.7.17 | -      | SQLite      | SQLite-3.7.17 |
| B.  | 3.30.1 | -      | SQLite      | SQLite-3.30.1 |
| C.  | 3.7.17 | 0.9.9  | sqlightning | LMDB_0.9.9    |
| D.  | 3.7.17 | 0.9.16 | sqlightning | LMDB_0.9.16   |

To benchmark a single binary takes approximately 4 minutes to complete:

```sh
for name in SQLite-3.30.1 SQLite-3.7.17 ; do
  seq 3 | while read i ; do
    make $name.html && mv $name.html $name-$i.html ;
  done ;
done
```

# References

- The
  [Fedora Spec file for "sqlite3"](https://apps.fedoraproject.org/packages/sqlite/sources/)
  lists dependencies.
- The [documentation](https://sqlite.org/whynotgit.html#getthecode) linking to
  the [official SQLite GitHub mirror](https://github.com/sqlite/sqlite)
- ["sqlightning" repository](https://github.com/LMDB/sqlightning)
- Early benchmarking <https://pastebin.com/B5SfEieL> of 3.7.17
- Benchmarking
  <https://github.com/google/leveldb/blob/master/benchmarks/db_bench_sqlite3.cc>

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
