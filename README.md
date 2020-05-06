<!-- SPDX-License-Identifier: AGPL-3.0-only -->
<!-- SPDX-FileCopyrightText: 2020 The LumoSQL Authors, 2019 Oracle -->
<!-- SPDX-ArtifactOfProjectName: LumoSQL -->
<!-- SPDX-FileType: Documentation -->
<!-- SPDX-FileComment: Original by Dan Shearer, 2020 -->

<a href="https://opensource.org"><img height="150" align="right" src="https://opensource.org/files/OSIApprovedCropped.png" alt="Open Source Initiative Approved License logo"></a>  <br><br><br><br><br><br><br>
  
  
# LumoSQL

## About LumoSQL

LumoSQL is SQLite with pluggable storage backends, benchmarking and other
features.

LumoSQL is not a fork of SQLite, using a tool called ```not-forking``` to keep
in sync with various upstreams.  

LumoSQL has no interest in replicating the work of sqlite.org, even if we could.

# Where to Start

The [LumoSQL Documentation](https://lumosql.github.io) which covers quickstart,
licensing, architecture, projectr aims and a knowledgebase of SQLite-related
code among many other things. 

You can learn about [contributing to LumoSQL](./CONTRIBUTING.md) .

## About the LumoSQL Project

LumoSQL started in December 2019 as a combination of two embedded data storage C language libraries:
[SQLite](https://sqlite.org) and [LMDB](https://github.com/LMDB/lmdb). LumoSQL
is an updated version of Howard Chu's 2013
[proof of concept](https://github.com/LMDB/sqlightning) combining the codebases. 

Dan Shearer did the original source tree archaeology, patching and test builds.
Keith Maxwell joined shortly after and contributed version management to the
Makefile and the benchmarking tools.

The goal of the LumoSQL Project is to create and maintain an improved version of
SQLite. This aim and related aims are covered in detail in the [[LumoSQL docs]](https://lumosql.github.io).

LumoSQL is supported by the [NLNet Foundation](https://nlnet.nl).

