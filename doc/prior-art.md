Prior Art for LumoSQL
======================

Dan Shearer
dan@shearer.org
February 2020

LumoSQL has many antecedents and relevant codebases.  This document is intended
to be a terse list of published source code for reference of LumoSQL
developers. Detailed discussion should be in the LumoSQL documentation web pages.


# List of Prior Art

| Project | Last modified | Description   |
| ------------- | ------------- | --------|
| [sqlightning](https://github.com/LMDB/sqlightning)  | 2013 | SQLight ported to the LMDB key-value store |
| [SQLHeavy](https://github.com/btrask/sqlheavy)  | 2013 | SQLite ported to LevelDB, LMDB, RocksDB and more, with a key-value store library abstraction |
| [libkvstore](https://github.com/btrask/libkvstore) | 2013 | The backend library used by SQLHeavy |
| [SQLite 4](https://sqlite.org/src4/tree?ci=trunk) | 2014 | Abandoned new version of SQLite with improved backend support and other features |
| [Sleepycat/Oracle BDB](https://github.com/hyc/BerkeleyDB) | current(?) | Disusedin open source, since Oracle changed the license, the API template for most of the k-v btree stores around
| [Sleepycat/Oracle BDB-SQL](https://github.com/hyc/BerkeleyDB/tree/master/docs/bdb-sql) | current(?) | Port of SQLite to use the bdb backend | 
| [rqlite](https://github.com/rqlite/rqlite) | current | Distributed database with networking and Raft consensus on top of sqlite nodes |
| [Bedrock](https://github.com/Expensify/Bedrock) | current | WAN-replicated blockchain multimaster database built on SQLite. Has MySQL emulation |
| [sql.js](https://github.com/kripken/sql.js/) | current | SQLite compiled to JavaScript WebAssembly through Emscripten |


