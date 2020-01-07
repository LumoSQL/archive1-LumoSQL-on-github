# Benchmarking

## Quick start

```sh
export DATA=../../../../data     # or wherever you keep it
npm run dev                      # check everything looks OK
npm run build && npm run export  # build production assets and static site
python3 -m http.server --directory __sapper__/export  # or any server
unset DATA                       # otherwise tests fail
```

## Overview

1. Several runs make up a data **set**
2. A **run** includes separate reports on different versions, it can be
   represented as a directory
3. A **report** shows the results of different tests for a single version, it
   can be represented as an HTML file
4. This benchmarking compares different **versions** for example upstream SQLite
   3.7.17 is a version
5. Comparisons are made across different **tests**, tests typically have a name
   and a value

### 1. Versions

| V.  | SQLite | LMDB   | Repository  | Name          |
| --- | ------ | ------ | ----------- | ------------- |
| A.  | 3.7.17 | -      | SQLite      | SQLite-3.7.17 |
| B.  | 3.30.1 | -      | SQLite      | SQLite-3.30.1 |
| C.  | 3.7.17 | 0.9.9  | sqlightning | LMDB_0.9.9    |
| D.  | 3.7.17 | 0.9.16 | sqlightning | LMDB_0.9.16   |

```
A. 3.7.17 2013-05-20 00:56:22 118a3b35693b134d56ebd780123b7fd6f1497668
B. 3.30.1 2019-10-10 20:19:45 18db032d058f1436ce3dea84081f4ee5a0f2259ad97301d43c426bc7f3df1b0b
C. 3.7.17 c896ea8 LMDB_0.9.9  7449ca6
D. 3.7.17 c896ea8 LMDB_0.9.16 5d67c6a
```

### 2. Tests

```
Test 1: 1000 INSERTs
Test 2: 25000 INSERTs in a transaction
Test 3: 100 SELECTs without an index
Test 4: 100 SELECTs on a string comparison
Test 5: 5000 SELECTs
Test 6: 1000 UPDATEs without an index
Test 7: 25000 UPDATEs with an index
Test 8: 25000 text UPDATEs with an index
Test 9: INSERTs from a SELECT
Test 10: DELETE without an index
Test 11: DELETE with an index
Test 12: A big INSERT after a big DELETE
Test 13: A big DELETE followed by many small INSERTs
Test 14: DROP TABLE
```

## Design choices

This project:

- uses ES Modules to ease later integration into a Svelte site
- does not use a module bundler like "rollup" for simplicity
- has 100% test coverage for `src/utils/`

## Prerequisites

- Node JS >= 12, for ES Modules support
- git, for install a fork of mocha, see below

## Tests

This project uses the [Mocha](https://mochajs.org) test framework. Mocha's
support for ES Modules with Node is a
[work in progress](https://github.com/mochajs/mocha/pull/4038). The version of
mocha specified in `package.json` is an experimental release with support for ES
Modules.
