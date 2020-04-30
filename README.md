<!-- SPDX-License-Identifier: AGPL-3.0-only -->
<!-- SPDX-FileCopyrightText: 2020 The LumoSQL Authors, 2019 Oracle -->
<!-- SPDX-ArtifactOfProjectName: LumoSQL -->
<!-- SPDX-FileType: Documentation -->
<!-- SPDX-FileComment: Original by Dan Shearer, 2020 -->

# LumoSQL

## About LumoSQL

LumoSQL is a combination of two embedded data storage C language libraries:
[SQLite](https://sqlite.org) and [LMDB](https://github.com/LMDB/lmdb). LumoSQL
is an updated version of Howard Chu's 2013
[proof of concept](https://github.com/LMDB/sqlightning) combining the codebases.

LumoSQL is not a fork of SQLite, using a tool called ```not-forking``` to keep in sync with various upstreams.

There is a huge amount of code and momentum around the SQLite codebase. LumoSQL 
brings some of this code together, in the form of pluggable storage backends, and 
other features.

You can read the [LumoSQL Documentation](https://lumosql.github.io) which
covers quickstart, licensing, architecture and a knowledgebase of
SQLite-related code among many other things. The Aims of the LumoSQL project
might be a good place to start.

You can learn about [contributing to LumoSQL](./CONTRIBUTING.md)

## About the LumoSQL Project

LumoSQL was started in December 2019 by Dan Shearer, who did the original source
tree archaeology, patching and test builds. Keith Maxwell joined shortly after
and contributed version management to the Makefile and the benchmarking tools.

The goal of the LumoSQL Project is to create and maintain an improved version of
SQLite.

LumoSQL is supported by the [NLNet Foundation](https://nlnet.nl).

If you are interesting in contributing to LumoSQL please see </CONTRIBUTING.md>.

