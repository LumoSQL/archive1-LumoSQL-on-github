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
├── bld-orig      Build artifacts for sqlite
├── lmdb          LMDB source code
└── sqlightning   sqlightning and sqlite source code (this repository)
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

4. Clone this repository:

   ```sh
   cd /run/host/var/srv/lumosql &&
   git clone git@github.com:maxwell-k/201912-sqlightning.git sqlightning`
   ```

   Or use the upstream sqlightning repository instead:
   `git@github.com:LMDB/sqlightning.git`.

5. Build `sqlite3` from the `orig` branch of the sqlightning repository:

   ```sh
   cd /run/host/var/srv/lumosql &&
   git -C sqlightning checkout orig &&
   mkdir bld-orig &&
   cd bld-orig &&
   ../sqlightning/configure &&
   cd .. &&
   make -C bld-orig &&
   bld-orig/sqlite3 --version
   ```

6. Download and checkout an appropriate version of LMDB, see below for and
   explanation of the choice of version:

   ```sh
   cd /run/host/var/srv/lumosql &&
   git clone git@github.com:LMDB/lmdb.git &&
   git -C lmdb checkout LMDB_0.9.16
   ```

7. In a clean directory, build sqlightning with a version number identifying the
   LMDB and sqlightning versions:

   ```sh
   cd /run/host/var/srv/lumosql &&
   git -C sqlightning checkout mdb &&
   rm -rf bld-mdb &&
   mkdir bld-mdb &&
   cd bld-mdb &&
   ../sqlightning/configure CFLAGS="-I../lmdb/libraries/liblmdb" &&
   cd .. &&
   make -C bld-mdb sqlite3.h &&
   printf '#undef SQLITE_SOURCE_ID\n' > version.txt &&
   printf '#define SQLITE_SOURCE_ID "%s %s %s"\n' \
     "$(git -C sqlightning rev-parse --short HEAD)" \
     "$(git -C lmdb describe --tags)" \
     "$(git -C lmdb rev-parse --short HEAD)" \
     >> version.txt &&
   sed -i '/^#define SQLITE_SOURCE_ID/rversion.txt' bld-mdb/sqlite3.h &&
   rm -f version.txt &&
   make -C bld-mdb &&
   bld-mdb/sqlite3 --version
   ```

# Speed tests / benchmarking

Assumes:

- sqlightning is compiled, and available at `./bld-mdb/sqlite3`
- the reference SQLite is available at `./bld-orig/sqlite3`
- `sqlite3` is installed as `/usr/bin/sqlite3`

Initial outline of steps, which take approximately 4 minutes to complete:

```sh
ln -s /usr/bin/sqlite3 &&
git -C sqlightning checkout benchmarking &&
tclsh sqlightning/tool/speedtest.tcl | tee output.html &&
rm sqlite3
```

Then repeat for the other versions.

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
| LMDB_0.9.11 | 2014-01-15 | ✓        | ?          |     6 |  443 | 273 |
| LMDB_0.9.12 | 2014-06-18 | ✓        | ?          |    12 |  516 | 333 |
| LMDB_0.9.13 | 2014-06-18 | ✓        | ?          |     3 |   28 |  22 |
| LMDB_0.9.14 | 2014-09-20 | ✓        | ?          |    23 | 2331 | 441 |
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
