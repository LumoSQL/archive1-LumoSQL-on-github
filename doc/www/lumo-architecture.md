<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
<!-- SPDX-FileCopyrightText: 2020 The LumoSQL Authors -->
<!-- SPDX-ArtifactOfProjectName: LumoSQL -->
<!-- SPDX-FileType: Documentation -->
<!-- SPDX-FileComment: Original by Dan Shearer, 2020 -->

LumoSQL Architecture
====================

![](./images/lumo-architecture-intro.jpg "Shanghai Skyline from Pxfuel, CC0 license, https://www.pxfuel.com/en/free-photo-oyvbv")



Table of Contents
=================

# Online Database Servers

![](./images/lumo-architecture-online-db-server.jpg "Overview of an online database server")

![](./images/lumo-architecture-online-db-server-scale.jpg "How an online database server scales")

# SQLite as an Embedded Database

![](./images/lumo-architecture-sqlite-overview.jpg "Overview of a SQLite being an embedded database server")

![](./images/lumo-architecture-sqlite-parts.jpg "The simplest view of the three parts to SQLite in typical embedded use")
<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
<!-- SPDX-FileCopyrightText: 2020 The LumoSQL Authors -->
<!-- SPDX-ArtifactOfProjectName: LumoSQL -->
<!-- SPDX-FileType: Documentation -->
<!-- SPDX-FileComment: Original by Dan Shearer, 2020 -->


LumoSQL
=======

![](./images/lumo-logo.png "LumoSQL logo")


Table of Contents
=================

Welcome to the LumoSQL project, which builds on the excellent
[SQLite](https://sqlite.org/).  LumoSQL is an SQL database which can be used in
embedded applications identically to SQLite, but also optionally with different storage
backends and other additional behaviour. LumoSQL emphasises benchmarking, code
reuse and modern database implementation.

* [Quick Start](./lumo-quickstart.md)
* [LumoSQL Project Aims](./lumo-project-aims.md)
* LumoSQL in Technical Detail
    + [Architecture](./lumo-architecture.md)
    + [Implementation](./lumo-implementation.md)
* [The LumoSQL Ecosystem](./lumo-ecosystem.md)
* [Benchmarking](./lumo-benchmarking.md)
* [Legal Aspects](./lumo-legal-aspects.md)
* [LumoSQL Documentation Standards](./lumo-doc-standards.md)


The following table shows how SQLite already has multiple deployment options:

# Why the Architecture Needs to Change

![](./images/lumo-architecture-sqlite-theoretical-future.jpg "Not Going to Happen: What SQLite would look like if it had multiple backends")

# LumoSQL Architecture


