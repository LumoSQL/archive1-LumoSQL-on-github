<!-- SPDX-License-Identifier: AGPL-3.0-only -->
<!-- SPDX-FileCopyrightText: 2020 The LumoSQL Authors, 2019 Oracle -->
<!-- SPDX-ArtifactOfProjectName: LumoSQL -->
<!-- SPDX-FileType: Documentation -->
<!-- SPDX-FileComment: Original by Dan Shearer, 2020 -->


Table of Contents
=================

   * [LumoSQL Interfaces Are Almost the Same as SQLite](#lumosql-interfaces-are-almost-the-same-as-sqlite)
   * [Table of Contents](#table-of-contents)
   * [Running LumoSQL](#running-lumosql)
   * [Building and Installing LumoSQL](#building-and-installing-lumosql)
      * [Directory layout](#directory-layout)
      * [Linux/Unix](#linuxunix)
         * [Build environment](#build-environment)
         * [Using the Makefile tool](#using-the-makefile-tool)
      * [Windows](#windows)
      * [Android](#android)


LumoSQL Interfaces Are Almost the Same as SQLite
================================================

Your interaction with the BDB SQL interface is almost identical to SQLite. You
use the same APIs, the same command shell environment, the same SQL statements,
and the same PRAGMAs to work with the database created by the BDB SQL interface
as you would if you were using SQLite.

To learn how to use SQLite, see the [SQLite Documentation](https://sqlite.org/docs.html).

That said, there are a few small differences between the two interfaces. These
are described in the remainder of this chapter. 


# Running LumoSQL

libraries and a command line shell are built with the following names:

    ```lumosql```

    This is the command line shell. It operates identically to the SQLite sqlite3 shell.

    ```liblumosql```

    This is the library that provides the LumoSQL SQL interface. It is the equivalent of the SQLite libsqlite3 library.

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



## Windows

LumoSQL is not supported on Windows as of March 2020. We are aiming for May 2020. Want to help?

## Android

LumoSQL is not supported on Android as of March 2020. We are aiming for July 2020. Want to help?

