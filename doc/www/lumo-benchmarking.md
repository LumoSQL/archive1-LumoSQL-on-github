<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
<!-- SPDX-FileCopyrightText: 2020 The LumoSQL Authors -->
<!-- SPDX-ArtifactOfProjectName: LumoSQL -->
<!-- SPDX-FileType: Documentation -->
<!-- SPDX-FileComment: Original by Dan Shearer, 2020 -->


Table of Contents
=================

   * [About Benchmarking](#about-benchmarking)
   * [Lack of Benchmarking Quality](#lack-of-benchmarking-quality)
   * [LumoSQL Benchmarking](#lumosql-benchmarking)
      * [Context](#context)
      * [Purpose](#purpose)
      * [SQLite interfaces](#sqlite-interfaces)
      * [Principles](#principles)
      * [Developer groups](#developer-groups)
      * [LumoSQL test harnesses](#lumosql-test-harnesses)
         * [TCL Tests](#tcl-tests)
         * [SQL Logic Test](#sql-logic-test)
         * [C speed tests](#c-speed-tests)
         * [Web Framework Test](#web-framework-test)
      * [Computer architectures and operating systems](#computer-architectures-and-operating-systems)
   * [List of Relevant Benchmarking and Test Knowledge](#list-of-relevant-benchmarking-and-test-knowledge)

About Benchmarking
==================

The [LumoSQL project aims](./lumo-project-aims.md) include:

> A Privacy-compliant Open Source Database Platform with Modern Design and Benchmarking.

The reason benchmarking is included is because that is largely unique in the
field of SQL databases, and certainly in the SQLite landscape.

Benchmarking is a big part of LumoSQL, to determine if changes are an
improvement. The trouble is that SQLite and other top databases are not really
benchmarked in a realistic and consistent way, despite SQL server benchmarking
using tools like TPC-C from [tpc.org](http://tpc.org) being an obsessive
industry in itself, and many testing tools released with SQLite, Postgresql,
MariaDB etc. But in practical terms there is no way of comparing the most-used
databases with each other, or even of being sure that the tests that do exist
are in any way realistic, or even of simply reproducing results that other
people have found.  LumoSQL covers so many codebases and use cases that better
SQL benchmarking is a project requirement. Benchmarking and testing overlap,
which is addressed in the code and documentation.

The well-described [testing of SQLite](https://sqlite.org/testing.html)
involves some open code, some closed code, and many ad hoc processes. Clearly
the SQLite team have an internal culture of testing that has benefitted the
world. However that is very different to testing that is reproducible by
anyone, which is in turn very different to reproducible reproducible by anyone,
and that is even without considering whether the benchmarking is a reasonable
approximation of actual use cases.

Lack of Benchmarking Quality
============================

In 2017 a helpful paper was published by [Purohith,Mohan and
Chidambaram](https://www.cs.utexas.edu/~vijay/papers/apsys17-sqlite.pdf) on the
topic of "The Dangers and Complexities of SQLite Benchmarking". Since the first
potential problem is that this paper itself is in error, LumoSQL repeated
the literature research component. We conclude that the paper is correct in stating:

> When we investigated 16 papers from the 2015-2017
> whose evaluation included SQLite, we find that none report
> all the parameters required to meaningfully compare
> results: ten papers do not report any parameters [17–26],
> five do not report the sync mode [27–31], while only
> one paper reports all parameters except write-ahead log
> size [32]. Without reporting how SQLite was configured,
> it is meaningless to compare SQLite results.

LumoSQL found three more papers published in 2017-2019, with similar flaws.
To the extent the results of these papers rely on SQLite testing (and for most
it is a central component) then these papers are nonsense. There are no better
or more careful results available outside the academic world. And this is for
SQLite alone, something that has relatively few parameters compared to the
popular online SQL databases. The field of SQL databases in general is even
more poorly benchmarked.

To highlight how poorly SQL benchmarking is done: there are virtually no test
harnesses that cover encrypted databases and/or encrypted database connections,
despite encryption being frequently required, and despite crypto implementation
decisions making a very big difference in performance.

It is fair to say that benchmarking SQLite and SQL databases is very difficult.
LumoSQL is developing some solutions we think will practically benefit
thousands of projects used on the internet, and hopefully change their practice
based on information they can verify for themselves.

LumoSQL Benchmarking
====================

In many respects benchmarking is one of the key drivers and validators for the
entire LumoSQL project. Benchmarking and testing is a vital means of
communication between the project and its users, and provides a common language
across time, code trees and use cases.

It is also a plain fact that it will be easy to compare SQL solutions for the
first time across different backends. When there is just a commandline switch
between testing an SQLite application running on an LMDB backend or a LevelDB
backend, the situation is controlled enough to make useful statements about
which performs better under what load.

This section sets out the approach to benchmarking that the LumoSQL project
will adopt from February to April 2020.

## Context

LumoSQL combines several independent pieces of software to offer an alternative
to the SQLite software available from <https://sqlite.org> ("SQLite"). It is
developed in the knowledge of other alternative implementations documented
elsewhere.

There are a large number of tests for SQLite, both open source and proprietary,
and its performance has improved remarkably since 2013. The author is not aware
of any public benchmarking results comparing alternative implementations.
<https://sqlite.org> does not include public test run results. At present any
claims of test coverage are difficult to verify; there is little information
published about the configurations tested: which hardware, virtual machines,
container images or libc implementations are tested?

As a project we recognise the overlap between our plans for benchmarking and the
need to have robust integration tests. To measure performance we must measure
the time it takes to perform an expected behaviour in a known environment. To
date some of our benchmarking work has highlighted unexpected behaviour, leading
to issues in the tracker and remediation.

Not all of the benchmarks and tests that we have reviewed use the public
application programming interface (API). We will focus on benchmarks and tests
that do.

We recognise that some of this work may be better characterised as testing than
benchmarking.

## Purpose

By benchmarking we mean quantitative measurement of performance. Our
benchmarking work is designed to inform decisions made by two groups of people:

1. Maintainers: ourselves, as maintainers of the project
2. Users: other developers, as potential users who might apply our project to a
   specific use case

Benchmarking will inform our documentation and through that our users — both as
initial recommendations to new users trying to quickly get started with LumoSQL
and to anyone who wants to challenge our results or to take them further.

Examples of decisions that might be made by maintainers:

- I am considering a change to the main code path to integrate a new feature,
  will the performance of LumoSQL suffer?

- I have identified a potential optimisation, is the performance benefit worth
  the additional complexity?

- I have implemented a new backend, should we make it the default?

Examples of decisions that might be made by users:

- I am interested in a new feature of LumoSQL, will the performance of my
  application suffer if I adopt LumoSQL in place of SQLite ?

- I have these requirements for a system, which LumoSQL backend should I choose?

We aspire to a circular scenario where:

1. our benchmarking informs the maintainers and users and
2. reports back from real world systems using LumoSQL inform further refinement
   of our benchmarking

The area of benchmarking represents a great opportunity for community
contribution, our benchmarking is as open source as everything else.

## SQLite interfaces

Two interfaces are suitable for benchmarking:

1. the `sqlite3` command line interface
2. the SQLite C application programming interface (API)

Both allow a user to submit SQL statements for processing. Benchmarking efforts
so far have concentrated on the command line interface.

As we add LumoSQL features, for example row level encryption, this will need to be 
benchmarked as well as tested, and that is out of scope for this document. 

## Principles

At this stage we do not plan to write new tests ourselves. We plan to identify
and make use of suitable open source test suites, including those written for
other SQL databases. We may need to edit, adapt or repair existing tests.

All of our benchmarking should be stable, public and reproducible. By public we
mean that: results are easily accessible online without payment. By reproducible
we mean:

- clear instructions including steps to recreate the published results are
  available
- any software used in the benchmarking is available under an open source
  license

We will not be able to measure and compare the performance of all of the
features of LumoSQL or SQLite. We plan to prioritise widely used features,
listen to the community and be open to contributions.

Our final principle is that a benchmarking or test suite that is not run is
worse than useless. Right now LumoSQL is a young project, but as authors we
believe historical tests only belong in the _git_ history.

## Developer groups

For the purposes of benchmarking we assigned developers that use SQLite into two
groups, those using:

1. embedded style SQL statements, typically developing for heavily resource
   constrained deployments, who are likely to use SQL to simply store and
   retrieve values and those using

2. online style SQL statements, typically developing for server or PC
   deployments, who are likely to a wider range of the supported SQL features

The embedded style of statement is typically used within the application process
space, the code written by these developers is often tightly coupled with the
SQLite library. The online style of SQL statement is typically more loosely
coupled with the database implementation and these developers may switch to
execute similar SQL statements on different databases. Further this second style
of SQL statement is more likely to result in long lasting transactions.

## LumoSQL test harnesses

LumoSQL started from SQLite and uses some SQLite tests. We plan to add other
open source tests. At <https://www.sqlite.org/testing.html> there are
descriptions of eight test harnesses, although some of those are proprietary.
Three of the eight are particularly relevant; we include detail about these and
another test harness we intend to adopt below.

We understand that the SQLite team runs a comprehensive set of tests before each
release. We intend to provide the community with a public record of reproducible
test results and regular runs.

### TCL Tests

Our objective in running these tests will be to quantify performance. These
tests use the `sqlite3` API.

These tests form a part of the SQLite repository and are available from a git
mirror.

If we discover that these tests are not well-suited to benchmarking and are
still maintained we may incorporate them into the LumoSQL benchmarking as
quality control.

### SQL Logic Test

Our objective in running these tests will be to quantify performance. These
tests use the `sqlite3` API to compare the results of queries with the same 
queries sent to other databases over ODBC (noting there is also an ODBC driver for SQLite.) 

We understand that this was originally designed for correctness testing; we
believe it may well lend itself to benchmarking.

<https://sqlite.org/testing.html> describes this a major test harness running a
large number of queries. As such we may focus on a narrower subset of these
tests.

This test suite is available in a [fossil repository], with a corresponding
[wiki]. Some [results] are documented publicly.

[wiki]: https://www.sqlite.org/sqllogictest/doc/trunk/about.wiki
[fossil repository]: https://www.sqlite.org/sqllogictest/dir?name=src&type=tree
[results]:
  https://www.sqlite.org/sqllogictest/wiki?name=Differences+Between+Engines

Later outside  the few months scope; we may benchmark different versions of
other peoples' database software. If we don't, we certainly hope that other 
people do using the tools we have developed.


### C speed tests

Our objective in running these tests will be to quantify performance. These
tests use the C API.

`speedtest1.c` appears to be very actively maintained by <https://sqlite.org>,
the file has a number of different contributors and has frequent commits.

`mptest.c` and `threadtest3.c` look promising for testing async access. See the 
notes previously about the unsophisticated concurrency handling we have already
demonstrated in SQLite. 


### Web Framework Test

Our objective in running these tests will be to quantify performance, from the
perspective of the second developer group. These tests use the C API.


We plan to identify a test or benchmarking suite for a popular language or web
framework that exercises a database. We will compare performance running this
suite with LumoSQL and other popular database engines.

## Computer architectures and operating systems

Initially we will focus on performance on 64 bit x86 processors running Linux.
We will look for differences across up to five different common Linux
distributions. One of the fist changes we will make to the environment is adding
memory constraints.

Benchmarking in the following environments is of interest but not in scope
immediately for January to March 2020:

- 32 bits, ideally on 32 bit virtualised hardware
- BSD
- Windows
- Android
- other processor architectures

# List of Relevant Benchmarking and Test Knowledge

There is a section in the [Full Knowledgebase Relevant to LumoSQL](./lumo-relevant-knowledgebase.md) on benchmarking. Everything in this
section appears at least as a line item in the Full Knowledgebase.

The 2017 paper [Dangers and complexity of sqlite3 benchmarking](https://www.cs.utexas.edu/~vijay/papers/apsys17-sqlite.pdf) talks at length about why benchmarking in general is so difficult, and using SQLite as a worked example. The abstract says:

> Benchmarking systems in a repeatable fashion is complex and  error-prone.
> The systems  community has repeatedly  discussed  the  complexities  of
> benchmarking and how to properly report benchmarking results.   Using the
> example of SQLite, we examine the current state of  benchmarking  in  industry
> and  academia.   We  show that changing just one parameter in SQLite can
> change the  performance  by  11.8X,  and  that  changing  multiple parameters
> can  lead  up  to  a  28X  difference  in  performance.  We find that these
> configuration parameters are often not set or reported in academic research,
> leading to incomplete and misleading evaluations

[Sysbench](https://github.com/akopytov/sysbench) is a multithreaded generic
benchmarking tool, with one well-supported use case being networked SQL
servers, and [MySQL in particular](https://www.percona.com/blog/2019/04/25/creating-custom-sysbench-scripts/)
. There is no reason why SQLite cannot work with Sysbench, and there is some
evidence ([for example](https://github.com/bloomberg/comdb2/pull/1377)) that
this has already been done. However as of March 2020 this has not been done for
LumoSQL. 

