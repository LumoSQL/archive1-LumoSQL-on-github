<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
<!-- SPDX-FileCopyrightText: 2020 The LumoSQL Authors -->
<!-- SPDX-ArtifactOfProjectName: LumoSQL -->
<!-- SPDX-FileType: Documentation -->
<!-- SPDX-FileComment: Original by Dan Shearer, 2020 -->

![](./images/lumo-legal-aspects-intro.png "XXXXXXXX")



# LumoSQL Licensing

The [LumoSQL Project Aims](lumo-projet-aims.md) include this:

> Legal promise: LumoSQL will not come with legal terms less favourable than 
> SQLite. LumoSQL will try to improve the legal standing and safety worldwide
> as compared to SQLite.

To achieve this:

* New LumoSQL code is licensed under the [MIT License](https://opensource.org/licenses/MIT), as used by many large corporations worldwide
* LumoSQL documentation is licensed under the [Creative Commons](https://creativecommons.org/licenses/by-sa/4.0/)
* Existing and future SQLite code is relicenced by the act of being distributed under the terms of the MIT license
* Open Source code from elsewhere, such as backend data stores, remain under the terms of the original license except where distribution under MIT effectively relicenses it
* Open Content documentation from elsewhere remains under the terms of the original license. No documentation is used in LumoSQL unless it can be freely mixed with any other documentation. 

LumoSQL users gain certainty as compared with SQLite users because they have a
license that is recognised in jurisdictions worldwide. 

LumoSQL users do not lose any rights. For example, the MIT license permits use
with fully proprietary software, by anyone. 

While MIT does require users to include a copy of the license and the copyright
notice, the software can remove the sentence requiring this from the license (thus
re-licensing LumoSQL.)

# In Detail: the SQLite Public Domain Licensing Problem

There are numerous reasons other than licensing why SQLite is less open source
than it appears, and these are covered in the [LumoSQL Landscape](./lumo-landscape.md). As to licensing, SQLite is distributed as
Public Domain software, and this is mentioned by D Richard Hipp in his [2016 Changelog Podcast Interview](https://changelog.com/podcast/201). Although he is aware of the problems, Hipp has decided not to introduce changes.

The [Open Source Initiative](https://opensource.org/node/878) explains the Public Domain problem like this:

> “Public Domain” means software (or indeed anything else that could be
> copyrighted) that is not restricted by copyright. It may be this way because
> the copyright has expired, or because the person entitled to control the
> copyright has disclaimed that right. Disclaiming copyright is only possible
> in some countries, and copyright expiration happens at different times in
> different jurisdictions (and usually after such a long time as to be
> irrelevant for software). As a consequence, it’s impossible to make a
> globally applicable statement that a certain piece of software is in the
> public domain.

Germany and Australia are examples of countries in which Public Domain is not
normally recognised which means that legal certainty is not possible for users
in these countries who need it or want it. This is why the Open Source
Initiative does not recommend it and nor does it appear on the [SPDX License List](https://spdx.org/licenses/).

The SPDX License List is a tool used by many organisations to understand where they stand legally with the millions of lines of code they are using. David A Wheeler has produced a helpful [SPDX Tutorial](https://github.com/david-a-wheeler/spdx-tutorial) . All code and documentation developed by the LumoSQL project has a SPDX identifier.

# History

SQLite Version 1 used the gdbm key-value store. This was under the GPL and
therefore so was SQLite. gdbm is limited, and is not a binary tree. When
Richard Hipp replaced it for SQLite version 2, he also dropped the GPL. 


# Encryption Issues

Local laws
EU laws
Facts of Privacy and security

# LumoSQL Requirements and Decisions



