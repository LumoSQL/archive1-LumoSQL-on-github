LumoSQL Storage System
======================

Dan Shearer
dan@shearer.org
Febrary 2020

The goals of LumoSQL require a new storage system to be added to the SQLite
code from which LumoSQL is derived.  This document proposes a modern storage
system with several features that are in advance of every other widely-used
database. LumoSQL is already the first major SQL database to move away from
batch processing, since it has a backend that does not use Write-Ahead Logs.
LumoSQL also needs to be able to use both the original SQLite and additional
storage mechanisms, and any or all of these storage backends at once. Not all
future storage will be on local disk, or btree key-values.

# Table of contents
1. [Write-ahead Logging in Transactional Databases](#WALs)
2. [Single-level Store](#SingleLevelStore)
3. [WALs in SQLite](#WALsInSQLite)
4. [Design for Multiple Storage Backends In LumoSQL](#MultipleBackends)
5. [Design for SLS in LumoSQL](#SLSInLumoSQL)

# Write-ahead Logging in Transactional Databases <a name="WALs"></a>

[Write-ahead Logging in Transactional Databases](https://en.wikipedia.org/wiki/Write-ahead_logging) has been the only
way since the 1990s or before that atomicity and durability are provided in
databases. A version of same technique is used in filesystems, where is is
called [journalling](https://en.wikipedia.org/wiki/Journaling_file_system).
Write-ahead Logging (WAL) is a method of making sure that all modifications to
a file are first written to a separate log, and then they are merged into a
master file in a later step. WALs seek to address issues with concurrent
transactions, and reliability in the face of crashes or errors. There are
decades of theory around how to implement WAL, and it is a significant part of
any University course in database internals. As well as somewhat-reliable
commit and rollback, it is the WAL that lets a database have online backup, and
point-in-time recovery. Every WAL feature and benefit comes down to being able
to have a stream of atomic operations that can be replayed forwards or
backwards.

The more a WAL-based database tries to be to real time, the more expensive it is to
keep all WAL functionality working. WAL is inherently batch-oriented.

The WAL implementation in the most common networked databases is comprehensive
and usually kept as a rarely-seen technical feature. Postgresql is an exception, 
going out of its way to inform administrators how the WAL system works and what 
can be done with access to the log files.

WAL references for the most common networked databases:

* [Postgresql](https://www.postgresql.org/docs/12/wal-intro.html)
* [SQL Server](https://docs.microsoft.com/en-us/sql/relational-databases/sql-server-transaction-log-architecture-and-management-guide?view=sql-server-ver15)
* [Oracle Log Writer Process](https://docs.oracle.com/en/database/oracle/oracle-database/19/cncpt/process-architecture.html#GUID-B6BE2C31-1543-4504-9763-6FFBBF99DC85)
* [MySQL ReDo Log](https://dev.mysql.com/doc/refman/8.0/en/optimizing-innodb-logging.html)
* [MariaDB Undo Log](https://mariadb.com/kb/en/library/innodb-undo-log/)

Companies have invested billions of Euros into these codebases with stability
and reliability as their first goal. And yet, even with all the runtime
advantages of huge resources and stable datacentre environments - even they
can't make WALs fully deliver on reliability. 

For comparison, Postgresql uses WAL, and despite not being intended for
embedded use cases, and despite having a large amount of code dedicated to safe
WAL handling, Postgresql still requires its users to make compromises regarding
reliability. 

[[ fixme add the WAL mitigation evidence here , including "https://dzone.com/articles/postgresql-
why-and-how-wal-bloats which describes a few of the tradeoffs of merge frequency vs
reliability in the case of a crash." ]]

# Single-level Store <a name="SingleLevelStore"></a>
SLS is done by the OS

# WALs in SQLite <a name="WALsInSQLite"></a>
SQLite WALs are special

The [SQLite WAL]( https://www.sqlite.org/draft/wal.html) requires multiple
files to be maintained in synch, otherwise there will be corruption. Unlike the
other databases listed here, SQLite has no pre-emptive corruption detection and
only fairly basic on-demand detection.


# Design for Multiple Storage Backends in LumoSQL <a name=MultipleBackends"></a>

Background
----------

As a compatible replacement for SQLite, LumoSQL can only have improved storage
if it has multiple storage backends, because the original always needs to be
available. For the forseeable future, SQLite changes and improvements need to
be reflected in LumoSQL, which means that the implementation of multiple
backends needs to be a minimally invasive patchset to SQLite, ideally one that can be
automatically generated.

Requirements for Multiple Backends
----------------------------------

* Needs to continue working without human modification when new releases of SQLite come out
* Needs to have a way of excluding the bits of the LumoSQL test suite that don't apply to new backends
* Needs to have a way of adding to the LumoSQL test suite for new backends
* Needs at minimum three backends: btree (the existing SQLite btree, ported to a new backend system); a test backend such as text or csv; and the LMDB backend.

Process For any given release of SQLite
---------------------------------------


