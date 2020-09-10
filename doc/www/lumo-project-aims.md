<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
<!-- SPDX-FileCopyrightText: 2020 The LumoSQL Authors -->
<!-- SPDX-ArtifactOfProjectName: LumoSQL -->
<!-- SPDX-FileType: Documentation -->
<!-- SPDX-FileComment: Original by Dan Shearer, 2020 -->


Table of Contents
=================

   * [Overall Objective of LumoSQL](#overall-objective-of-lumosql)
   * [Table of Contents](#table-of-contents)
   * [Aims](#aims)
   * [Short Term Goals](#short-term-goals)


![](./images/lumo-project-aims-intro.jpg "Mongolian horseback archery, rights request pending from https://www.toursmongolia.com/")

Overall Objective of LumoSQL
============================

	To create Privacy-compliant Open Source Database Platform with Modern Design and Benchmarking,
	usable either embedded or online.

This is the guide for every aspect of the project, which will ensure that
LumoSQL offers features that money can't buy, and drawing together an
SQLite-related ecosystem.

The rest of this document will be updated frequently in 2020, and over time
will become more strategic and with less listing of specific new features.

Aims
====

* SQLite upstream promise: LumoSQL will not fork SQLite, and will offer 100%
  compatibility with SQLite by default, and contribute to SQLite where possible.
  This especially includes the SQLite user interface mechanisms of pragmas, 
  library APIs, and commandline parameters.

* Legal promise: LumoSQL will not come with legal terms less favourable than 
  SQLite. LumoSQL will try to improve the legal standing and safety worldwide
  as compared to SQLite.

* Developer contract: LumoSQL will have stable APIs ([Application Programming Interfaces](https://en.wikipedia.org/wiki/Application_programming_interface#Libraries_and_frameworks)) for features found in multiple unrelated SQLite downstream projects:
  backends, frontends, encryption, networking and more. 

* Devops contract: LumoSQL will reduce risk by making it possible to omit
  compliation of unneeded features, and will have stable ABIs ([Application Binary Interfaces](https://en.wikipedia.org/wiki/Application_binary_interface)) so as to not break dynamically-linked applications.

* Ecosystem creation: LumoSQL will offer consolidated contact, code curation, bug tracking,
  licensing, and community communications across all these features from
  other projects. Bringing together SQLite code contributions under one umbrella reduces 
  technical risk in many ways, from inconsistent use of threads to tracking updated versions.


Short Term Goals
================

* LumoSQL will have three canonical and initial backends: btree (the existing
SQLite btree, ported to a new backend system); the LMDB backend; and the BDB
backend. Control over these interfaces will be through the
same user interface mechanisms as the rest of LumoSQL, and SQLite.

* LumoSQL will improve SQLite quality and privacy compliance by introducing
optional on-disk checksums for storage backends including to the original
SQLite btree format.  This will give real-time row-level corruption detection

* LumoSQL will improve SQLite quality and privacy compliance by introducing
optional storage backends that are more crash-resistent than SQLite btree (such as LMDB)
and more oriented towards complete recovery (such as BDB)

* LumoSQL will improve SQLite integrity in persistent storage by introducing
optional row-level checksums

* LumoSQL will provide the benefits of Open Source and an open project
by continuing to accept and review contributions in an open way, using
github and having diverse contributors, and being careful to use open
source licenses

* LumoSQL will improve SQLite design by intercepting APIs at a very small
number of critical choke-points, and giving the user optional choices at
these choke points. The choices will be for alternative storage backends,
front end parsers, encryption, networking and more, all without removing
the zero-config and embedded advantages of SQLite

* LumoSQL will provide a means of tracking upstream SQLite, by making
sure that anything other than the API chokepoints can be synched at each
release, or more often if need be

* LumoSQL will provide updated, public testing tools, with results published
and instructions for reproducing the test results. This also means
excluding parts of the LumoSQL test suite that don't apply to new backends

* LumoSQL will provide benchmarking tools, otherwise as per the testing
tools

* LumoSQL will ensure that new code remains optional by means of modularity at
compiletime and also runtime. By illustration of modularity, at compiletime
nearly all 30 million lines of the Linux kernel can be excluded giving just 200k
lines. Runtime modularity will be controlled through the same user interfaces 
as the rest of LumoSQL.

* LumoSQL will ensure that new code may be active at once, eg
multiple backends or frontends for conversion between/upgrading from one
format or protocol to another. This is important to provide continuity and
supported upgrade paths for users, for example, users who want to become
privacy-compliant without disrupting their end users

* Over time, LumoSQL will carefully consider the potential benefits of dropping
some of the most ancient parts of SQLite when merging from upstream, provided
it does not conflict with any of the other goals in this document. Eliminating 
SQLite code can be done by a similar non-forking mechanism as used to keep in synch
with the SQLite upstream. Patches will be offered to sqlite.org

