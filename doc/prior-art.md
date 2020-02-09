Prior Art for LumoSQL
======================

Dan Shearer
dan@shearer.org
February 2020

LumoSQL has many antecedents and relevant codebases.  This document is intended
to be a terse list of published source code for reference of LumoSQL
developers. Detailed discussion should be in the LumoSQL documentation web pages.

Everything listed below is open source.


# List of SQLite Code-related Prior Art

SQLite code has been incorporated into many other projects, and besides there are many relevant K-V stores and libraries.

| Project | Last modified | Description   |
| ------------- | ------------- | --------|
| [sqlightning](https://github.com/LMDB/sqlightning)  | 2013 | SQLight ported to the LMDB key-value store |
| [SQLHeavy](https://github.com/btrask/sqlheavy)  | 2013 | SQLite ported to LevelDB, LMDB, RocksDB and more, with a key-value store library abstraction |
| [libkvstore](https://github.com/btrask/libkvstore) | 2013 | The backend library used by SQLHeavy |
| [SQLite 4](https://sqlite.org/src4/tree?ci=trunk) | 2014 | Abandoned new version of SQLite with improved backend support and other features |
| [Sleepycat/Oracle BDB](https://github.com/hyc/BerkeleyDB) | current | The original ubiquitous Unix K-V store, now disused in open source since Oracle changed the license in 2013; the API template for most of the k-v btree stores around. Now supports replication | 
| [Sleepycat/Oracle BDB-SQL](https://github.com/hyc/BerkeleyDB/tree/master/docs/bdb-sql) | current(?) | Port of SQLite to use the bdb backend | 
| [rqlite](https://github.com/rqlite/rqlite) | current | Distributed database with networking and Raft consensus on top of sqlite nodes |
| [Bedrock](https://github.com/Expensify/Bedrock) | current | WAN-replicated blockchain multimaster database built on SQLite. Has MySQL emulation |
| [sql.js](https://github.com/kripken/sql.js/) | current | SQLite compiled to JavaScript WebAssembly through Emscripten |

# List of On-disk File Format-related Prior Art

The on-disk file format is important to many SQLite use cases, and introspection tools are both important and rare. Other K-V stores also have third-party on-disk introspection tools.

| Project | Last modified | Description |
| ------- | ------------- | ----------- |
| [A standardized corpus for SQLite database forensics](https://www.sciencedirect.com/science/article/pii/S1742287618300471) | current | Sample SQLite databases and evaluations of 5 tools that do extraction and recovery from SQLite, including Undark and SQLite Deleted Records Parser |
| [FastoNoSQL](https://github.com/fastogt/fastonosql) | current | GUI inspector and management tool for on-disk databases including LMDB and LevelDB |
| [Undark](https://github.com/inflex/undark) | 2016 | SQLite deleted and corrupted data recovery tool |
| [SQLite Deleted Records Parser](https://github.com/mdegrazia/SQLite-Deleted-Records-Parser) | 2015 | Script to recover deleted entries in an SQLite database |
| [lua-mdb](https://github.com/catwell/cw-lua/tree/master/lua-mdb) | 2016 | Parse and investigate LMDB file format |

