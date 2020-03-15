<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
<!-- SPDX-FileCopyrightText: 2020 The LumoSQL Authors -->
<!-- SPDX-ArtifactOfProjectName: LumoSQL -->
<!-- SPDX-FileType: Documentation -->
<!-- SPDX-FileComment: Original by Dan Shearer, 2020 -->

![](./images/lumo-ecosystem-intro.png "LumoSQL logo")


The LumoSQL Ecosystem
=====================

LumoSQL is not a fork of SQLite. LumoSQL integrates several bodies of code
including SQLite into a new database. The idea of building on SQLite isn't new.
The reach and breadth of the SQLite code is astonishing and far more than the
LumoSQL project realised at the beginning. Before LumoSQL nobody has tried to
document this as one whole.


Table of Contents
=================



The SQLite Landscape
====================

The Internet runs on data stored in rows, ie Relational Databases. There are 
many exceptions and alternatives but this is where the deciding data is stored:

* in routers that direct internet traffic
* in mobile phones that enable the user to navigate the internet
* business applications or those that deal with reconciling important numbers
* in millions of everyday applications, such as Wikipedia

And the most widely-used relational database is almost certainly SQLite.

In addition there are SQLite-derived projects that address traditional online
database use cases in a similar way only in 4%-10% of size of code. The SQLite
landscape feels reminiscent of XFree86 in the early 2000s, a massively useful
project that became less responsive to modern needs.  The analogy is imperfect,
as SQLite is very actively developed (within the project's strict scope) and
can be relied on to keep producing a quality database library. But like X.org,
LumoSQL seeks to be inclusive, rigorous and accepting of the many exciting
SQLite-based features fragmented across the web.

The databases to compare LumoSQL against are those that together are the
most-used on the internet today: 

* Oracle MySQL - open source, with closed source licensing available, ubiquitous on the internet
* MariaDB - a mostly-compatible fork of MySQL, perhaps taking over from MySQL on the internet
* Postgresql - open source, highly compliant with SQL standards,
* Oracle's traditional RDBMs - the closed source database that makes its owners the most money
* Microsoft SQL Server - ubiquitous in business applications, less common on the internet 
* SQLite - source code freely available, highly compliant with most SQL standards

All of these are online databases, while SQLite is embedded - more on that below.


LumoSQL and The SQLite Project 
------------------------------

This section pulls out distinctive features of the sqlite.org project that
matter to LumoSQL.  Some are negative features to which LumoSQL wants to
respond by way of an improvement or extension, but others are more like a
spring that gives LumoSQL a great start in new use cases. Some of these points
are mentioned by D Richard Hipp in his [2016 Changelog Podcast Interview](https://changelog.com/podcast/201).

**sqlite.org is a responsive and responsible upstream**, for issues they feel
are in scope. For example, see section 4.1.4 in
<https://www.sqlite.org/testing.html> where Manuel Rigger is credited for his
work in raising many dozens of bugs, which as can be seen at
<https://www.sqlite.org/src/timeline?y=t&u=mrigger&n=all> have been addressed
promptly. LumoSQL should not fork SQLite, partly because the developers are doing a 
very good job at maintaining the things they care about, and partly because SQLite has a high 
profile and attracts technical review.

**Sqlite.org is entirely focussed on its existing scope and traditional user needs,
(https://sqlite.org/about.html) and there is evidence the project delivers on
this**.  This scope focus imposes strict limits, for example “Think of SQLite not as
a replacement for but as a replacement for fopen()” which eliminates many of
the possibilities LumoSQL is now exploring that go well beyond any version of
fopen(). Many things that SQLite can used for are [declared out of
scope](https://sqlite.org/whentouse.html) by the SQLite project including those
that are high concurrency, write-intensive, or networked. LumoSQL feels there is a tension between
this scope for SQLite and the 5G IoT world very many applications are all three, and many SQLite deployments
are tending towards disregarding the warnings from the SQLite project. 

**Sqlite has a very strict and reliable view on maintaining backwards
compatibility both binary and API (except when it comes to encryption, see
further down.)** The Sqlite foundation aims to keep SQLite3 interfaces and
formats stable until the year 2050 years, as once requested by an airframe
construction company (Airbus). Whatever happens in years to come SQLite has
definitely delivered on this to date. This means that there are many things
SQLite cannot do which LumoSQL can, and it also means that LumoSQL needs to
suppor strict compatibility with SQLite3 interfaces and formats at least as an
option if not the default.

**Sqlite.org not entirely an open project.** No code is accepted from contributors
external to the company HWACI, which is owned by D Richard Hipp, the original
author and lead of SQLite. From the [SQLite copyright page](https://www.sqlite.org/copyright.html):

	In order to keep SQLite completely free and unencumbered by copyright, the project does not accept
	patches. If you would like to make a suggested change, and include a patch as a proof-of-concept, 
	that would be great. However please do not be offended if we rewrite your patch from scratch. 

That fact is not hidden in any way, and there have been many years of
successful SQLite use on this basis. It is definitely not acceptable under the
Next Generation Internet initiative nor (quite possibly) under draft and
current EU laws or at least recommendations, as discussed elsewhere in SQLite
documentation. On the other hand, there is a [contribution
policy](https://system.data.sqlite.org/index.html/doc/trunk/www/contribute.wiki)
. LumoSQL is a fully open project, and since it started in 2019 not 1999,
LumoSQL does not have to navigate historical decisions in the way SQLite does.

The [SQLite Long Term Support](https://sqlite.com/lts.html) page states:

	“In addition to supporting SQLite through the year 2050, the developers also
	promise to keep the SQLite [C-language API](https://sqlite.com/cintro.html) and
	[on-disk format](https://sqlite.com/fileformat2.html) fully backwards
	compatible. This means that applications written to use SQLite today should be
	able to link against and use future versions of SQLite released decades in the
	future.”

As well as the success of this policy and its obvious advantages, there are some 
serious problems with it too:

	* this kind of backwards-compatibility was one of the problems that led
	  to Microsoft Windows stagnation for years, see [The Case Against
	  Backwards Compatibility](https://joomla.digital-peak.com/blog/178-the-case-against-backward-compatibility).
	  The problem isn't clear-cut, as shown by [Why is ABI Stability Important?](https://www.dpdk.org/blog/2019/10/10/why-is-abi-stability-important/)
	  and Greg Kroah-Hartman's paper [Stable API Nonsense](https://www.kernel.org/doc/Documentation/process/stable-api-nonsense.rst),
	  noting that the Linux distribution companies such as Red Hat charge money to maintain a time-limited
	  stable API.  LumoSQL has the luxury of choosing what extensions to stable formats and APIs to introduce, and how.

	* Since SQLite crypto implementation details are secret, any encrypted database 
	  created by the official closed-source SQLite is almost certainly incompatible 
	  with any other encryption project by third parties, despite file format compatibility 
	  being a major feature of SQLite. Yet with encryption being a requirement for 
	  many applications, this means there is no guarantee of SQLite file format
	  compatibility.

	* this rigid rule becomes difficult when it comes to a long-term
	  storage format discussions.  See below for discussion of how the
	  SQLite binary format has almost zero internal integrity checking.
	  LumoSQL aims to add options to address this problem.

**Sqlite is less open source than it appears**. The existance of so many SQLite
spin-offs is evidence that SQLite code is highly available. However there are
several aspects of SQLite that mean it cannot be considered open source, in
ways that are increasingly important in the 21st century:

	* Public domain is not is not recognised in some countries such as
	  Germany and Australia, which means that legal certainty is not
          possible for users in these countries who need it or want it. Public
	  Domain is not a valid grant of right, which is why it is not one of
	  the [Open Source Initiative licenses](https://opensource.org/licenses) nor
	  does it appear on the [SPDX License List](https://spdx.org/licenses/).

	* sqlite.org charge USD6000 for “perpetual right-to-use for the SQLite
          source code", and implies that this right-to-use has grants actual
          legal benefits. This is an additional reason why the SQLite public domain
	  licensing approach cannot be open source, because you have to pay money 
	  in order to be sure where you stand.

        * As sqlite.org states, the most important test harness is only available commercially. 
          This is perfectly legal, but is definitely not an open source approach at all.

	* The only supported encryption code is closed source, and even the mailing list 
	  for discussing this is not public. 

This really matters, because MariaDB now publish cryptographic and network
scaling code under their Business Source License, which requires "Power Users"
to pay.  These pressures are not compatible with modern open source.

**SQLite Code has Many Independent Downstreams** Multiple front ends, backends
and network replication, clustering and encryption solutions exist today. This
is all code that appears to be working, or at least it has not obviously
decayed even if it might not work as advertised, and some it is very actively
developed and supported. Much of this code has been inspected to a first level
by LumoSQL, some of it has been built and run. Just because the foregoing can
be made to work in a demonstration does not mean that it is suitable for
production, nor that it should be part of LumoSQL design. But it speaks of a
very strong demand for more features, and a rich pool of experimentation to
learn from. This is covered in more detail in the next section. 

**Sqlite file format does not have technical or organisational longevity
built-in** Sqlite.org commit to supporting the on-disk file format until 2050,
without evidence of an enduring legal body. Similarly, claims are made for the
reliability of the on-disk format even though there are virtually no intergity
measures built in.  As can be seen from [the published
specification](https://www.sqlite.org/fileformat2.html) the use of checksums is
limited to pages in the writeback journal, and WAL records, and one 32-bit
integer for when the official closed source encryption is used. Therefore file
format provides no general means of validating the data it contains. It would
be possible to extend the file format in a backwards-compatible manner to
include such checks, but that does not appear to have been discussed or
suggested. This does not provide modern standards of reliable at-rest storage,
transport and archiving, and it does not meet minimum privacy standards
including those mandated by law in many countries, especially the EU.
sqlite.org is not unique in this, it is only fair to say that other SQL
databases implement this feature awkwardly or not at all, and that it is
particularly obvious in the case of SQLite because it an embedded local on-disk
database library. SQLite could be the first database to have a modern reliable
on-disk format, and it would not be difficult to make it so except for promises 
not to break bit-for-bit compatibility. This issue is dealt with in more detail in 
[LumoSQL architecture](./lumo-architecture) and [implementation](./lumo-implementation.md) documentation.

**the current Sqlite on-disk file format may be less robust than it seems**.
Unscientific ad-hoc enquiries indicate that many IT professionals are familiar
with SQLite file corruption. Examples of ad-hoc enquiries are: asking for a
show of hands in a room of developers, speaking to the maintainers of SQLite
file inspection tools, and chatting to Android developers.  The LumoSQL team as
of March 2020 are looking at how to artificially create crashes and corruptions
as part of testing (and perhaps benchmarking).

SQLite Downstreams
==================

There is still a lot for LumoSQL to explore because there is just so much code, but
as of March 2020 we are confident code could be assembled from here and there
and there on the internet to demonstrate the following features:

-   SQLite with Berkely bdb backend
-   SQLite with LevelDB backend
-   SQLite with network access from quite a few projects, only some of them listed
-   SQLite with MySQL-compatible frontend, from Oracle
-   SQLite with MySQL-compatible frontend, from Bedrock
-   SQLite with LMDB at WAL-level and then replicated LMDB with consensus, from ActorDB
-   SQLite with private blockchain-esque for fast replication to 6-8 nodes, from Bedrock
-   SQLite with GIS extensions
-   SQLite accessible locally over ODBC
-   SQLite with at-rest encryption in many different ways

And plenty more. 

Due to the fragmented nature of SQLite landscape, what we *cannot* demonstrate is:

-   APIs for the above features in the same codebase
-   any of these interesting features running together in the same
    binary or using the same database files
-   consolidated contact, code curation, bug tracking, licensing across
    these features and projects

and that is why there really isn't an SQLite ecosystem, just a landscape. 

For those users that even realise there are extended feature versions of SQLite
around, they have to pick and choose which of these features they want, and
usually that means going without some other feature, and it just has a chaotic
feel to it. On the other hand, while SQLite has achieved so much, there are
compelling reasons to look for an alternative. LumoSQL aims to be that
alternative.


LumoSQL 2019 Prototype Conclusions And Lessons
==============================================

The original LumoSQL question was: “does the 2013 sqlightning work still stand
up, and does it represent a way forward?” 

The answers are many kinds of both Yes and No:

1.  **Yes**, with some porting and archeology, sqlightning does still
    work and is relevant. It did move the world forward, it just took a while.
2.  **No**, SQLite in 2020 is not vastly slower than sqlightning, as it
    was in 2013. SQLite has improved its btreee code. We have not yet
    run the concurrency testing which seems likely to show benefits for
    using LMDB.
3.  **Yes**, sqlightning does represent a way forward to a more robust,
    private and secure internet. This is no longer an argument about
    pure speed, although LumoSQL is not slower than SQLite as far as we
    know to date.
4.  **No**, nobody can be really definitive about SQLite this way or
    that, because of the dearth of benchmarking or testing and complete
    absence of published results. We have started to address this
    already. 
5.  **Yes**, LMDB underneath SQLite has some key benefits over SQLite
    including in concurrency support and file integrity.
6.  **No**, we are not going to carry forward any of the LMDB prototype code. 
    But it will forever live on fondly in our hearts.

Facts Established by 2019 LumoSQL Prototype
-------------------------------------------

Using both technical and non-technical means, the LumoSQL Prototype project
established in a matter of a few person-weeks that:

-   The SQLite project has built-in problems (some of them in this chapter)
    that LumoSQL can address in part, while remaining a compatible superset of SQLite
    at both API and on-disk level, and not forking SQLite.

-   The porting and archeology involved in getting sqlightning going as
    an LMDB backend to SQLite was quite a lot more work than taking existing working
    code for other K-V store backends, most of which are currently maintained and in use. 

-   All major SQL databases including SQLite suffer from historical
    architecture decisions, including the use of Write Ahead Logs to do
    concurrency, and lack of validation by default at the data store
    level. This is a particularly big failing for SQLite given its emphasis on 
    file format on IoT devices.

-   All major SQL databases other than SQLite are in the millions of
    lines of source code, compared to SQLite at 350k SLOC . The
    difference is not due to the embedded use case. Some are tens of millions.

-   There is a great lack of published, systematic test results for databases. There is no
    online evidence of SQLite tests being run regularly, and there
    are no published results from running SQLite test code . The same is true
    for all the other major databases. Even with continuous integration tools,
    do any open source database developers include testing in their published
    CI results? We could not find any.

-   There is no published SQLite benchmarking. LumoSQL has done some,
    and published it. We plan to do a lot more.

-   Benchmarking databases in a way which both reflects the real world and is
    also repeatable and general is difficult, and while SQLite is easier than
    the other databases because of its simplicity, the paper [Dangers and
    complexity of sqlite3
    benchmarking](https://www.cs.utexas.edu/~vijay/papers/apsys17-sqlite.pdf)
    highlights the difficulty "...changing just one parameter in SQLite can change
    the performance by 11.8X... up to 28X difference in performance".  We have
    developed some benchmarking solutions we think will practically benefit
    thousands of projects used on the internet, and hopefully change their practice
    based on information they can verify for themselves.

Lessons Learned from sqlightning
--------------------------------

* LMDB and SQLite Btree.c are quite similar and very sophisticated KV
   stores compared to all others in open source, of which we have looked at 
   Berkely DB (BDB) by Sleepycat/Oracle, LMDB, Redis, RocksDB, LevelDB and Aerospike.
   Still in 2020 there are almost no other KV stores that are fully
   MVCC, except Badger, written in Go: https://github.com/dgraph-io/badger .

* btree.c:sqlite3BtreeBeginTrans had some internal LMDB cursor
   structures. Rewrote using the LMDB API instead; more tests passed .

* The SQL spec allows a transaction to be opened without specifying whether it is RO
   or RW. The sqlightning code handled the upgrade case of RO->RW by copying the
   transaction to a new (larger) RW structure, copying its cursors and restarting.
   This results in an "internal error" when the original btree.c returns "database
   is locked"; we have now fixed this bug in the modified btree.c to match the behaviour
   of the original btree.c .

* There are only limited tests available for SQLite (visible in public)
   that exercise concurrency, races and deadlocks. There is a lot of
   scope for these sorts of problems and we need to address them at many
   levels including testing specifically for this.

* SQLite does not have sophisticated concurrent transaction handling
   compared to Postgresql, Oracle and MariaDB etc, being much more ready
   to return 'LOCKED' rather than some concurrency algorithm. We will
   return to this problem in later versions of LumoSQL.

