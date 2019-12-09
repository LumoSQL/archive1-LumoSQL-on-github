# Index

- Regressions, test failures, opportunities and more are tracked as
  [issues](https://github.com/maxwell-k/201912-sqlightning/issues)
- Short term planning and progress reporting is tracked on a
  [project board](https://github.com/maxwell-k/201912-sqlightning/projects/1)
- Branches:

  <dl>
  <dt>`benchmarking`</dt>
  <dd>this README and simplified benchmarking code (default)</dd>
  <dt>[`mdb`](https://github.com/maxwell-k/201912-sqlightning/tree/mdb)</dt>
  <dd>the sqlightning code base</dd>
  <dt>[`orig`](https://github.com/maxwell-k/201912-sqlightning/tree/orig)</dt>
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
   sudo mkdir /var/srv/lumosql  &&
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
   explanation of the choice of 0.9.9:

   ```sh
   cd /run/host/var/srv/lumosql &&
   git clone git@github.com:LMDB/lmdb.git &&
   git -C lmdb checkout LMDB_0.9.9
   ```

7. Build sqlightning:

   ```sh
   cd /run/host/var/srv/lumosql &&
   git -C sqlightning checkout mdb &&
   mkdir bld-mdb &&
   cd bld-mdb &&
   ../sqlightning/configure CFLAGS="-I../lmdb/libraries/liblmdb" &&
   cd .. &&
   make -C bld-mdb &&
   bld-mdb/sqlite3 --version
   ```

# Speed tests / benchmarking

Assumes:

- sqlightning is compiled, and available at `./bld-mdb/sqlite3`
- the reference SQLite is available at `./bld-orig/sqlite3`
- `sqlite3` is installed as `/usr/bin/sqlite3`

Initial outline of steps:

```sh
git -C sqlightning checkout benchmarking &&
ln -s /usr/bin/sqlite3 &&
tclsh sqlightning/tool/speedtest.tcl | tee output.html &&
rm sqlite3
```

Then repeat for the other versions.

# References

- The
  [Fedora Spec file for "sqlite3"](https://apps.fedoraproject.org/packages/sqlite/sources/)
  lists dependencies.
- The [documentation](https://sqlite.org/whynotgit.html#getthecode) linking to
  the [Official git mirror](https://github.com/sqlite/sqlite)
- ["sqlightning" repository](https://github.com/LMDB/sqlightning)
- Early benchmarking <https://pastebin.com/B5SfEieL> of 3.7.17
- Benchmarking
  <https://github.com/google/leveldb/blob/master/benchmarks/db_bench_sqlite3.cc>

# Why 0.9.9?

`mc_orig` was removed and `mc_backup` added to `mdb.c` in
<https://github.com/LMDB/lmdb/commit/be47ca766713f55e5b3abd18120514fdad7d90f2>
first released in `LMDB_0.9.7` on 14 August 2013. `LMDB_0.9.8` was 9 September
2013 and `LMDB_0.9.9` was 24 October 2013.
`58b473f3d5570fca94b88398e0e4314208a077cd` made adapted `sqlightning` to this
change on 12 September 2013. So first try `LMDB_0.9.8`, but this fails with:

`sqlite3.c:38156:2: error: unknown type name ‘mdb_hash_t’`

Likely need
[this commit](https://github.com/LMDB/lmdb/commit/01dfb2083dd690707a062cabb03801bfad1a6859),
found through a
[GitHub comparison](https://github.com/LMDB/lmdb/compare/LMDB_0.9.8...LMDB_0.9.9)
