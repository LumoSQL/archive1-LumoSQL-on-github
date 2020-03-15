<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
<!-- SPDX-FileCopyrightText: 2020 The LumoSQL Authors -->
<!-- SPDX-ArtifactOfProjectName: LumoSQL -->
<!-- SPDX-FileType: Documentation -->
<!-- SPDX-FileComment: Original by Dan Shearer, 2020 -->

![](./images/lumo-project-aims-intro.jpg "XXXXXXXXXX")

Overall Objective of LumoSQL
============================

	To create Privacy-compliant Open Source Database Platform with Modern Design and Benchmarking,
	usable either embedded or online.

This is the guide for every aspect of the project, which will ensure that
LumoSQL offers features that money can't buy, and drawing together an
SQLite-related ecosystem.

The rest of this document will be updated frequently in 2020, and over time
will become more strategic and with less listing of specific new features.

Table of Contents
=================

   * [Overall Objective of LumoSQL](#overall-objective-of-lumosql)
   * [Table of Contents](#table-of-contents)
   * [Aims](#aims)
   * [Short Term Goals](#short-term-goals)

Aims
====

* SQLite upstream promise: LumoSQL will not fork SQLite, and will offer 100%
  compatibility with SQLite by default, and contribute to SQLite where possible

* Developer contract: LumoSQL will have stable APIs for features found in
  multiple unrelated SQLite downstream projects: backends, frontends,
  encryption, networking and more

* Devops contract: LumoSQL will reduce risk by making it possible to omit
  compliation of many features, and will have stable ABIs so as to not break
  dynamically-linked applications.

* Ecosystem creation: LumoSQL will offer consolidated contact, code curation, bug tracking,
  licensing, and community communications across all these features from
  other projects


Short Term Goals
================

* LumoSQL will improve SQLite quality and privacy compliance by introducing
optional on-disk checksums including in the existing official SQLite btree
format.

* LumoSQL will improve SQLite quality and privacy compliance by introducing
optional storage backends that are more crash-resistent, starting with LMDB
followed by others.

* LumoSQL will improve SQLite integrity in persistent storage by introducing
optional row-level checksums.

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
and instructions for reproducing the test results

* LumoSQL will provide benchmarking tools, otherwise as per the testing
tools

* LumoSQL will ensure that new code remains optional (as an extreme
example of modularity, despite having nearly 30 million lines of code, a
usable Linux kernel can be compiled from around 200k lines.)

* LumoSQL will also ensure that new code can all be active at one, eg
multiple backends or frontends for conversion between/upgrading from one
format or protocol to another. This is crucial to provide continuity and
supported upgrade paths for users, for example, users who want to become
privacy-compliant without disrupting their end users

* LumoSQL will carefully consider the benefits of dropping some of the most
ancient parts of SQLite when merging from upstream, provided it does not
conflict with any of the other goals in this document.

