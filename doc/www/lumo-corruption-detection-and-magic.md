<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
<!-- SPDX-FileCopyrightText: 2020 The LumoSQL Authors -->
<!-- SPDX-ArtifactOfProjectName: LumoSQL -->
<!-- SPDX-FileType: Documentation -->
<!-- SPDX-FileComment: Original by Dan Shearer, 2020 -->

Table of Contents
=================

   * [Summary of SQL Database Corruption Detection](#summary-of-sql-database-corruption-detection)
   * [SQLite and Integrity Checking](#sqlite-and-integrity-checking)
   * [LumoSQL Checksums and the SQLite On-disk File Format](#lumosql-checksums-and-the-sqlite-on-disk-file-format)
   * [Design for Corruption Detection](#design-for-corruption-detection)


![](./images/lumo-corruption-detection-and-magic-intro.png "XXXXXXXX")

# Summary of SQL Database Corruption Detection

One of the short-term goals stated in the [LumoSQL Project Aims](./lumo-project-aims.md) is:

> LumoSQL will improve SQLite quality and privacy compliance by introducing
> optional on-disk checksums for storage backends including to the original
> SQLite btree format. This will give real-time row-level corruption detection.

It seems quite extraordinary that in 2020 none of the major online databases -
not Posgresql, Oracle, MariaDB, SQLServer or others - have the ability to check
during a SELECT operation that the row being read from disk is exactly the row
that was previously written. There are many reasons why data can get modified,
deleted or overwritten outwith the control of the database, and the ideal way
to respond to this is to notify the database when a corrupt row is accessed.
All that is needed is for a hash of the row to be stored with the row when it
is written.

All the major online databases have the capacity for an external process to
check disk files for database corruption, as does SQLite. This is very
different from real-time integrity checking, and cannot be done in real time.

Knowing that a corruption problem is limited to a row or an itemised
list of rows reduces a general "database corruption problem" down to a bounded
reconstruction task. Users can have confidence in the remainder of a database
even if there is corruption found in some rows.

This problem has been recognised and solved inefficiently at the SQL level by various projects. Two of these are
[Periscope Data's Per-table Multi-database Solution](https://www.periscopedata.com/blog/hashing-tables-to-ensure-consistency-in-postgres-redshift-and-mysql) and [Percona's Postgresql Public Key Row Tracking](https://www.percona.com/blog/2018/10/12/track-postgresql-row-changes-using-public-private-key-signing/). By using SQL code rather than modifying the database internals there is a performance hit. Both these companies specialise in performance optimisation but choose not to apply it to this feature, suggesting they are not convinced of high demand from users.

Interestingly, all the big online databases have row-level security, which has many similarities to the problem of corruption detection. 

For those databases that offer encryption, this is effectively page-level or
column-based hashes and therefore there is corruption detection by implication.
However this is not row-based checksumming, and it is not on by default in any
of the most common databases.

It is possible to introduce a checksum on database pages more easily than for
every row, and transparently to database users. However, knowing a database
page is corrupt isn't much help to the user, because there could be many rows
in a single page.

# SQLite and Integrity Checking

The SQLite developers go to great lengths to avoid database corruption, within their project goals. Nevertheless, corrupted SQLite databases are an everyday occurance.

SQLite does have checksums already in some places:

* for the journal transaction log (superceded by the Write Ahead Log system)
* for each database page when using the closed-source SQLite Encryption Extension
* for each page in a WAL file

SQLite also has [PRAGMA integrity_check](https://www.sqlite.org/pragma.html#pragma_integrity_check) and
[PRAGMA quick_check](https://www.sqlite.org/pragma.html#pragma_quick_check)
which do partial checking, and which do not require exclusive access to the
database. These checks have to scan the database file sequentially and verify
the logic of its structure, because there are no checksums available to make it
work more quickly.

None of these are even close to the accuracy, reliability and speed of row-level corruption detection. 

SQLite does have a file change counter in its database header, in 
[offset 24 of the official file format](https://www.sqlite.org/fileformat.html), however this
is not itself subject to integrity checks nor does it contain information about the rest of the file,
so it is a hint rather than a guarantee.

SQLite needs row-level integrity checking even more than the online databases because:

* SQLite embedded and IoT use cases often involve frequent power loss, which is the most likely time for corruption to occur.
* an SQLite database is an ordinary filesystem disk file stored wherever the user decided, which can often be deleted or overwritten by any unprivileged process.
* it is easy to backup an SQLite database partway through a transaction, meaning that the restore will be corrupted
* SQLite does not have robust locking mechanisms available for access by multiple processes at once, since it relies on lockfiles and Posix advisory locking 
* SQLite provides the [VFS API Interface](https://www.sqlite.org/vfs.html) which users can easily misuse to ignore locking via the sql3_*v2 APIs
* the on-disk file format is seemingly often corrupted regardless of use case. Better evidence on this is needed but authors of SQLite data file recovery software (see listing in [SQLite Relevant Knowledgebase](./lumo-relevant-knowledebase)) indicates high demand for their services. Informal shows of hands at conferences indicates that SQLite users expect corruption.

sqlite.org has a much more detailed, but still incomplete, summary of [How to Corrupt an SQLite Database](https://www.sqlite.org/howtocorrupt.html).

# LumoSQL Checksums and the SQLite On-disk File Format 

The SQLite database format is widely used as a defacto standard. LumoSQL ships
with the lumo-backend-mdb-traditional which is the unmodified SQLite on-disk
format, the same code generating the same data. There is no corruption
detection included in the file format for this backend.  However corruption
detection is available for the traditional backend, and other backends that do
not have scope for checksums in their headers. For all of these backends,
LumoSQL offers a separate metadata file containing integrity information.

The new backend lumo-backend-mdb-updated adds row-level checksums in the header
but is otherwise identical to the traditional SQLite MDB format. 

There is an argument that any change at all is the same as having a completely
different format.  This is not a strong argument against adding checksums to
the traditional SQLite on-disk format because with encryption increasingly
becoming mandatory, the standard cannot apply. The sqlite.org closed-source SSE
solution is described as "All database content, including the metadata, is
encrypted so that to an outside observer the database appears to be white
noise." Other solutions are possible involving metadata that is not encrypted
(but definitely checksummed), but in any case, there is no on-disk standard for
SQLite databases with encryption.

# Design for Corruption Detection

All LumoSQL backends can have corruption detection enabled, with the metadata
stored either directly in the backend database files, or in a separate file.
When a user switches on checksums for a database, metadata needs to be stored.

This depends on two new functions needed in any case for labelling LumoSQL
databases provided by backend-magic.c: lumosql_set_magic() and lumosql_get_magic(). These functions add and
read a unique metadata signature to a LumoSQL database.

1. if possible magic is inserted into the existing header

2. if not a separate "metadata" b-tree is created which contains a key "magic"
and the appropriate value. get_magic() will look for the special metadata
b-tree and the "magic" key

After LumoSQL has determined how and where metadata will be stored, the high-level design for row-level checksums is:

1. an internally maintained row hash updated with every change to a row
2. If a corruption is detected on read, LumoSQL should make maximum relevant fuss. At minimum, [error code 11 is SQLITE_CORRUPT](https://www.sqlite.org/rescode.html#corrupt)
3. An additional SQL user command is added that exposes this hash in a column so that user-level logic can do not only corruption detection, but also change detection.

At a later stage a column checksum can be added giving change detection on a table, or corruption detection for read-only tables.

In the case where there is a separate metadata file, a function pair in lumo-backend-magic.c reads and writes a whole-of-file checksum for the database. This can't be done for where metadata is stored in the main database file.


