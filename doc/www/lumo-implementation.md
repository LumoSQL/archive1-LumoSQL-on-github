<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
<!-- SPDX-FileCopyrightText: 2020 The LumoSQL Authors -->
<!-- SPDX-ArtifactOfProjectName: LumoSQL -->
<!-- SPDX-FileType: Documentation -->
<!-- SPDX-FileComment: Original by Dan Shearer, 2020 -->


Table of Contents
=================

   * [LumoSQL Implementation](#lumosql-implementation)
   * [Table of Contents](#table-of-contents)
   * [Changes to SQLite](#changes-to-sqlite)
      * [Lockfile/tempfile Pushed to Backend](#lockfiletempfile-pushed-to-backend)
      * [SQLite API Interception Points](#sqlite-api-interception-points)
      * [SQLite Virtual Machine Layer](#sqlite-virtual-machine-layer)


LumoSQL Implementation
======================

![](./images/lumo-implementation-intro.jpg "Metro Station Construction Futian Shenzhen China, CC license, https://www.flickr.com/photos/dcmaster/36740345496")


# Changes to SQLite

## Lockfile/tempfile Pushed to Backend

SQLite API Interception Points
------------------------------

The process LumoSQL has largely completed as of March 2020 is:

1. Identify the correct API choke points to control, then
2. Find useful chunks of code we want to switch between at these choke
points to demonstrate the design.

   The API interception points are:

  1. Setup APIs/commandline/Pragmas, where we pass in info about what
front/backends we want to use or initialise. Noting that SQLite is
zero-config and so supplying no information to LumoSQL must always be an option.
Nevertheless, if a user wants to select a particular backend, or have
encryption or networking etc there will be some setup. Sqlite.org provides a
large number of controls in pragmas and the commandline already.

  2. SQL processing front ends. Code exists (see [Relevant Codebases](./lumo-relevant-codebases.md)
that implements MySQL-like behaviour in parallel with supporting SQLite semantics.
There is a choice codebases to do that with, covering different approaches to the problem.

  3. Transaction interception and handling, which in the case of the LMDB
backend will be pass-through but in other backends may be for replicated
storage, or backup. This interception point would be in ```wal.c``` if all
backends used a writeahead log and used it in a similar way, but they do not.
Instead this is where the new ```backend.c``` API interception point will be
used - see further down in this document.  This is where, for example, we can
choose to add replication features to the standard SQLite btree storage
backend.

  4. Storage backends, being a choice of native SQLite btree or LMDB today, and
swiftly after that other K-V stores. This is the choke point where we expect to
introduce [libkv](./lumo-relevant-codebases#libkv), or a modification of libkv.

  5. Network layers, which will be at all of the above, depending whether they
are for client access to the parser, or replicating transactions, or being
plain remote storage etc.

In most if not all cases it needs to be possible to have multiple choices
active at once, including the obvious cases of multiple parsers and multiple
storage backends, for example. This is because one of the important new use
cases for LumoSQL will be conversion between formats, dialects and protocols.

Having designed the API architecture we can then produce a single LumoSQL tree
with these choke point APIs in place and proof of two things:

1. ability to have stock-standard identical SQLite APIs and on-disk
btree format, and

2. an example of an alternative chunk of code at each choke point:
MySQL; T-pipe writing out the transaction log in a text file; LMDB .
Not necessarily with the full flexibility of having all code active at
once if that's too hard (ie able to take any input SQL and store in
any backend)

   and then, having demonstrated we have a major step forward for the entire world,

3. Identify what chunks of SQLite we really don't want to support any more.
   Like maybe the ramdisk pragma given that we can/should/might have an
in-memory storage backend, which initially might just be LMDB with overcommit
switched off. This is where testing and benchmarking really matters.

SQLite Virtual Machine Layer
----------------------------

In order to support multiple backends, LumoSQL needs to have a more general way
of matching capabilities to what is available, whether a superset or a subset of
what SQLite currently does. This needs to be done in such a way that it remains
easy to track upstream SQLite.

The SQLite architecture has the SQL virtual machine in the middle of everything:

`vdbeapi.c` has all the functions called by the parser
`vdbe.c` is the implementation of the virtual machine, and and it is
from here that calls are made into btree.c

All changes to SQLite storage code will be in vdbe.c , to insert an
API shim layer for arbitary backends. All BtreeXX function calls will
be replaced with backendXX calls.

`lumo-backend.c` will contain:

* a switch between different backends
* a virtual method table of function calls that can be stacked, for
layering some generic functionality on any backends that need it as
follows

`lumo-index-handler.c` is for backends that need help with index
and/or key handling. For example some cannot have arbitary length
keys, like LMDB. RocksDB and others do not suffer from this.
`lumo-transaction-handler.c` is for backends that do not have full
transaction support. RocksDB for example is not MVCC, and this will
add that layer. Similarly this is where we can implement functionality
to upgrade RO transactions to RW with a commit counter.
`lumo-crypto.c` provides encryption services transparently backends
depending on a decision made in lumo-backend.c, which will cover
everything except backend-specific metadata. Full disk encryption of
everything has to happen at a much lower layer, like SQLite's idea of
a VFS. The VFS concept will not translate entirely, because the very first
alternative backend is based on mmap, and which will need special handling. So we are for now expecting to implement a lumo-vfs-mmap.c and a lumo-vfs.c .
`lumo-vfs.c` provides VFS services to backends, and is invoked by
backends. `lumo-vfs.c` may call lumo-crypto for full file encryption
including backend metadata depending on the VFS being implemented.

Backend implementations will be in files such as `backend-lmdb.c`,
`backend-btree.c`, `backend-rocksdb.c` etc.

This new architecture means:

1. Features such as WALs or paging or network paging etc are specific to the backend, and invisible to any other LumoSQL or SQLite code.
2. Bug-for-bug compatibility with the orginal SQLite btree.c can be maintained (except in the case of encryption, which no open source users have access to anyway.)
3. New backends with novel features (and LMDB is novel enough, for a first example!) can be introduced without disturbing other code, and being able to be benchmarked and tested safely.




