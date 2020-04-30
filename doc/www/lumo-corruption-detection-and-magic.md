<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
<!-- SPDX-FileCopyrightText: 2020 The LumoSQL Authors -->
<!-- SPDX-ArtifactOfProjectName: LumoSQL -->
<!-- SPDX-FileType: Documentation -->
<!-- SPDX-FileComment: Original by Dan Shearer, 2020 -->

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
* the on-disk file format is seemingly often corrupted regardless of use case. Better evidence on this is needed but authors of SQLite data file recovery software (see listing in [SQLite Relevant Knowledgebase](./lumo-relevant-knowledebase)) indicates high demand for their servies. Informal shows of hands at conferences indicates that SQLite users expect corruption.

sqlite.org has a much more detailed, but still incomplete, summary of [How to Corrupt an SQLite Database](https://www.sqlite.org/howtocorrupt.html).

# LumoSQL Checksums and the SQLite On-disk File Format 

The SQLite database format is widely used as a defacto standard. LumoSQL ships
with the lumo-backend-mdb-traditional which is the unmodified SQLite on-disk
format, the same code generating the same data. There is no corruption detection for this backend.

The new backend lumo-backend-mdb-updated adds row-level checksums but is
otherwise identical to the traditional SQLite MDB format. There is an argument that
any change at all is the same as having a completely different format. 
This is not a strong argument against adding checksums to the
traditional SQLite on-disk format because with encryption increasingly becoming
mandatory, the standard cannot apply. The sqlite.org closed-source SSE
solution is described as "All database content, including the metadata, is
encrypted so that to an outside observer the database appears to be white
noise." Other solutions are possible involving metadata that is not encrypted
(but definitely checksummed), but in any case, there is no on-disk standard for
SQLite databases with encryption.

# Design for Corruption Detection

1. By default, an internally maintained row hash updated with every change to a row
2. This can be switched off if desired. But we want default to be on because we want people to
start realising how relatively common this actually is (yes, I'm guessing. But well-founded
guessing.)
3. If a corruption is detected on read, LumoSQL should make maximum relevant fuss. At minimum,
error code 11 is SQLITE_CORRUPT
4. Later, an additional SQL user command that exposes this hash so that user-level logic can do
not only corruption detection, but also change detection. That's a short-cut to one specific sort of
post-hoc trigger.
What I have not proposed is any kind of table-level hash protection.

That may work for some backends but not for others;  however if we were to
have a lumo-backend-magic.c file which:

1. if possible inserts magic into the existing header

2. if not creates a separate "metadata" b-tree(*) which contains a key
"magic" and the appropriate value; to recognise the file, first use
whatever mechanism one uses to decide if the file format is the one for
that particular (unmodified) backend, and if so look for the special
metadata b-tree and the "magic" key

(*) other meta-backends may share this special b-tree to do things we
haven't thought about yet

--------------------

Perhaps if we say that LumoSQL stores meta-data in a special metadata
btree (or whatever data structure our backend uses, we don't care about
their internal details) then we have a better access to all these things.
And we could even have per-table checksums in there if that is what we
want.

For example in lmdb-backend the table is translated to a btree called
Tab.(long_number) so if we also had one called Meta or Meta.(number)
there would be no clashes.

Hmmm, I just realised that the long_number there is sqlite3's idea of the
root page of the btree, so I'll want to see that things outside the
backend don't imagine that they can go and poke their nose directly in the
file at that location.  If it just treats it as an opaque value like a
filesystem i-node that's absolutely fine though.


* set_magic() in backend.c that says "set magic number for this file",
to that when creating a new database file, at an appropriate spot in
the header for that particular filetype we insert some magic. We
append the Lumo file format version number to this magic. I've only
looked at LMDB and SQLite btree formats so far, and both of them have
room in their page 0 metadata for this. In other words, "LumoSQL"
becomes a subtype of the file format, which must remain recognisable
to file handling tools. This will be a mandatory function for all
backends to implement and must be part of every database creation. I
suppose there may be some backend filetypes where you can't add
additional magic, I don't know what should be done there.

* get_magic() called by backend.c's open function that says "read the
magic number for this file to see if it is LumoSQL or not, and if so,
what backend type and format version number". Both set and get magic
will be actually implemented in lumo-backend-XXXX.c

* a function pair in backend.c (calling lumo-vfs.c or
lumo-vfs-mmap.c?) to write and read the whole-of-file checksum, which
is also stored in page 0 of the file, or whatever the metadata block
of the particular file format is called. This is a checksum updated on
backend.c's database_close() to be an SHA1 of the entire file.

The above functions mean the following examples work

    /usr/bin/sha1sum $file

should give the same result as

   /usr/bin/lumosql --sha1sum $file

where lumosql figures out what format the file is using get_magic, and
then extracts the sha1sum. This is corruption-detection-lite, it could
just be a dirty file. But it is an excellent start, way ahead of
anything that exists.

It does mean that there will be a delay when closing the database. And
backend.c's database_open() call should set the sha1sum field to zero
if it is opened for write.

***********************

These functions also mean that we can do this:

   /usr/bin/lumosql --file-info $file

to display the meta data (or say "This is not a valid LumoSQL file,
although we recognise it is an LMDB file")

which reminds me: sqlite does not use double-dash commandline
separators, only single dash. So I propose that everything we
implement in lumosql be --double-dash.

*********************

Extremely fast and widely-used hashing code is available from https://keccak.team/ .


