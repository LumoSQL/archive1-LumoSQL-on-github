<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
<!-- SPDX-FileCopyrightText: 2020 The LumoSQL Authors -->
<!-- SPDX-ArtifactOfProjectName: LumoSQL -->
<!-- SPDX-FileType: Documentation -->
<!-- SPDX-FileComment: Original by Claudio Calvelli, March 2020 -->


Table of Contents
=================

   * [Not-Forking Upstream Source Code Tracker](#not-forking-upstream-source-code-tracker)
   * [Table of contents](#table-of-contents)
   * [Upstream definition file <a name="user-content-upstream"></a>](#upstream-definition-file-)
      * [git](#git)
      * [download](#download)
   * [Modification definition file <a name="user-content-modification"></a>](#modification-definition-file-)
   * [Example Configuration directory <a name="user-content-example"></a>](#example-configuration-directory-)
   * [Notforking tool <a name="user-content-tool"></a>](#notforking-tool-)

Not-Forking Upstream Source Code Tracker
========================================

The LumoSQL project incorporates software from other projects and some of that
software needs some modifications.  Rather than fork our own version, we have
developed a mechanism which we call "notforking" to semi-automatically track
upstream changes.

The mechanism is similar to applying patches; however patches need to be
constantly updated as upstream sources changes, and the notforking mechanism
helps with that.

Each project tracked by notforking needs to define what to track, and what
changes to apply. This is done by providing a number of files in a directory;
the minimum requirement is an upstream definition file; other files can also be
present indicating what modifications to apply (if none are provided, the
upstream sources are used unchanged).

# Upstream definition file <a name="upstream"></a>

The file `upstream.conf` has a simple "key = value" format with one such
key, value pair per line: blank lines and lines whose first nonblank
character is a hash (`#`) are ignored; long lines can be split into multiple
lines by ending a line with a backslash meaning conitnuation into the
next line.

There is a special line format to indicate conditionals; currently, the
only condition which can be tested is whether the version number is in
a specified range, using the syntax:

```
ifver \[>= FIRST\_VERSION\] \[<= LAST\_VERSION\]
...
endif
```

If a key is present more than once, the last value seen wins; therefore,
it is possible to define a key inside a conditional block, and then to
define it again outside the block to provide a default value.

The only key which must be present is `vcs`, and there is no default.
It indicates what kind of version control system to use to obtain upstream
sources; the value is the name of a version control module defined by the
notforking mechanism; at the time of writing `git` and `download` are valid
values; in general, the documentation for the corresponding version control
module defines what else is present in the `upstream.conf` file; this document
describes briefly the configuration for the above two modules.

## git

The upstream sources are available via a public git repository; the following
keys need to be present:

- `repos` (or `repository`) is a valid argument to the `git clone` command.
- optionally, `user` and `password` can be specified to obtain access to the
repository.

## download

The upstream sources are released as published versions and downloaded
directly; the following keys need to be present:

- `uri` indicates where to obtain these sources, and can contain the special
symbol `%V` to indicate the version
- `compare` if present indicates what method to use to compare
two different version numbers; if omitted, it default to `version` which
compares sequences of letters alphabetically and sequences of digits
numerically (so for example `v10` is before `z` but after `v9`);
additionally, a suffix "-alpha" or "-beta" can be present and these
are considered older than the version number without suffix; this
handles most "normal" version numbers although it does not work with
weird versioning schemes like the ones used by INTERCAL compilers, for
example. At the time of writing, this is the only comparison method
provided.

TBC - we also need to say how to unpack the sources etc

# Modification definition file <a name="modification"></a>

There can be zero or more modification definition files in the configuration
directory; each file has a name ending in `.mod` and they are processed
in lexycographic order according to the "C" locale (rather than the current
locale, to guarantee consistent ordering). Note that only files are
considered; if the configuration directory contains subdirectories, these
are ignored.

The contents of each modification definition file are an initial part with
format similar to the Upstream definition file described above ("key = value"
pair, possibly with conditional blocks); this initial part ends with a line
containing just dashes and the rest of the file, referred to as "final
part", is interpreted based on information from the initial part.

The following keys are currently understood:

- `version`: the value is two strings separated by whitespace, indicating
a minimum and maximum version number to which this file applies; the
first string can have the special value "-" to indicate the earliest
possible version; the second string can be omitted to indicate the latest
possible version. One use of this key is to indicate that a modification
is only necessary up to a particular version, because for example that
modification has been accepted by upstream and is no longer necessary.
Another use of this key is to identify versions in which substantial
upstream changes make it difficult to specify a modification which works
for every possible version.
- `method`; the method used to specify the modification; currently, the
value can be either `patch`, indicating that the final part of the file is
in a format suitable for passing as standard input to the "patch" program;
or `replace` indicating that one or more files in the upstream must be
completely replaced; the final part of the file contains one or more
lines with format "old-file = new-file", where both are relative paths,
the first relative to the root of the extracted upstream sources; the
second path is relative to the configuration directory.

Other keys are interpreted depending on the value of `method`; there
are no other keys for the `replace` method, and the following for the
`patch` method:

- `options`: options to pass to the "patch" program (default: "-sp1")

# Example Configuration directory <a name="example"></a>

Obtaining SQLite sources and replacing btree.ci and btreeInt.h with the ones
from sqlightning, and applying a patch to vdbeaux.c:

File `upstream.conf`:

```
vcs   = git
repos = https://github.com/sqlite/sqlite.git
```

File `btree.mod`:

```
method = replace
--
src/btree.c    = files/btree.c
src/btreeInt.h = files/btreeInt.h
```

File `vdbeaux.mod`:
```
method = patch
--
--- sqlite-git/src/vdbeaux.c    2020-02-17 19:53:07.030886721 +0100
+++ new/src/vdbeaux.c      2020-03-21 13:52:24.861586555 +0100
@@ -2778,7 +2778,7 @@
      for(i=0; i<db->nDb; i++){
        Btree *pBt = db->aDb[i].pBt;
        if( sqlite3BtreeIsInTrans(pBt) ){
-        char const *zFile = sqlite3BtreeGetJournalname(pBt);
+        char const *zFile = BackendGetJournal(pBt);
          if( zFile==0 ){
            continue;  /* Ignore TEMP and :memory: databases */
          }
```

Files `files/btree.c` and `files/btreeInt.h`: the new contents.

A more complete example can be found in the directory "notforking/sqlite"
which tracks upstream updates from SQLite.

# Notforking tool <a name="tool"></a>

The `tool` directory contain a script, `notfork` which runs the notforking
mechanism on a directory.  Usage is:

tool/notfork CONFIG\_DIRECTORY OUTPUT\_DIRECTORY [-v VERSION | -c COMMIT\_ID]

where:

- CONFIG\_DIRECTORY is a notforking configuration directory as specified
in this document
- OUTPUT\_DIRECTORY is the place where the modified upstream sources will
be stored, and it can be either a directory created by a previous run of
this tool,  or a new directory (missing or empty directory)
- VERSION: ask for the specified VERSION
- COMMIT\_ID: for version control modules which support it, obtain a
specified commit ID rather than a published version; this is
incompatible with -v

if neither VERSION nor COMMIT\_ID is specified, the default is the latest
available version, if it can be determined

The tool will obtain the upstream sources, make a copy of the files which
are going to be modified, and attempt to apply all the required modifications;
if that succeeds, OUTPUT\_DIRECTORY/sources will contain the modified sources
ready to use; if that fails, an error message will explain the problem and
if possible suggest corrective action (for example, if `patch` determines
that a file has changed too much that it cannot figure out how to apply a
patch supplied, the error message will indicate this and suggest to obtain
a new patch for that version of the sources).


