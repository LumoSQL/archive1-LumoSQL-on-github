<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
<!-- SPDX-FileCopyrightText: 2020 The LumoSQL Authors -->
<!-- SPDX-FileType: Documentation -->

LumoSQL Implementation
======================

![](./images/lumo-implementation-intro.jpg "Metro Station Construction Futian Shenzhen China, CC license, https://www.flickr.com/photos/dcmaster/36740345496")


Table of Contents
=================

# Changes to SQLite

## Lockfile/tempfile Pushed to Backend

The original btree.h treats the WAL file as a lock file, and also makes it visible to the rest of SQLite. 

sqlite3PagerExclusiveLock


btree.c makes the "lock file" (which in btree.c is also the WAL) visible
to the upper levels, and I think this is wrong; this is something private
to the backend.  LMDB certainly considers it private and the file name is
not visible without looking inside mdb.c

It appears that there are only two uses of this "lock file" name both of
which we shouldbox get rid of.

First use: during a commit vdbeaux.c goes to poke its nose in it.  I think
this needs to go away with extreme prejudice and if appropriate move to
(the original) btree.c; the LMDB backend has no use for this.

Second use: if a database has been opened as temporary or "delete on
close" then it needs to delete both the main file and the lock file.
I'm thinking that in this case the database is private to whoever created
it and it can just ask LMDB to omit the lock file, and then nobody needs
to know the name it would have because it's not been created at all.
Perhaps I can make it a documented limitation, that if you ask for a
temporary file you don't go and figure out the (random) name it gets in
order to open it in another process.
