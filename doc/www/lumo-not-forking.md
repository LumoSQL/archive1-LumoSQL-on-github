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
   * [Not-forking tool <a name="user-content-tool"></a>](#not-forking-tool-)

Not-Forking Upstream Source Code Tracker
========================================

The LumoSQL project incorporates software from other projects and some of that
software needs some modifications.  Rather than fork our own version, we have
developed a mechanism which we call "not-forking" to semi-automatically track
upstream changes.

The mechanism is similar to applying patches; however patches need to be
constantly updated as upstream sources changes, and the not-forking mechanism
helps with that. The overall effect is something like git cherry-picking, 
except that it also copes with:
* human-style software versioning
* code that is not maintained in the same git repo
* code that is not maintained in git, but is just patches or in some other VCS
* custom processing that is needed to be run for a specific patch
* failing with an error asking for human intervention to solve differences with upstream

etc.

Each project tracked by not-forking needs to define what to track, and what
changes to apply. This is done by providing a number of files in a directory;
the minimum requirement is an upstream definition file; other files can also be
present indicating what modifications to apply (if none are provided, the
upstream sources are used unchanged).

# Upstream definition file <a name="upstream"></a>

The file `upstream.conf` has a simple "key = value" format with one such
key, value pair per line: blank lines and lines whose first nonblank
character is a hash (`#`) are ignored; long lines can be split into multiple
lines by ending a line with a backslash meaning continuation into the
next line.

There is a special line format to indicate conditionals; currently, the
only condition which can be tested is whether the version number is in
a specified range, using the syntax:

```
if version \[>\[=\] FIRST\_VERSION\] \[<\[=\] LAST\_VERSION\]
...
[else ...]
endif
```

If a key is present more than once, the last value seen wins; therefore,
it is possible to define a key inside a conditional block, and then to
define it again outside the block to provide a default value.

The only key which must be present is `vcs`, and there is no default.
It indicates what kind of version control system to use to obtain upstream
sources; the value is the name of a version control module defined by the
not-forking mechanism; at the time of writing `git` and `download` are valid
values; in general, the documentation for the corresponding version control
module defines what else is present in the `upstream.conf` file; this document
describes briefly the configuration for the above two modules.

Optionally, two other keys can be present: `compare` and `subtree`.

The `compare` key indicates what method to use to compare two different
version numbers; if omitted, it default to `version` which compares
"normal" software version numbers: sequences of digits compare
numerically, and sequences of letters compare alphabetically, with the
exception that a suffix "-alpha" or "-beta" cause the version to be
considered before the string without such suffix: examples of version
numbers in order are:

- `0.9a` < `0.9z` < `0.10` < `1.0` < `1.1-alpha` < `1.1-beta` < `1.1` < `1.1a`

This definition will even cope with the numbering scheme used by TeX and
METAFONT which are "Pi" and "e" respectively. The definition can be extended to
deal with version numbering schemes used by normal software, however it will
never work correctly with the version numbers used by some software such as the
[CLC-INTERCAL](https://en.wikipedia.org/wiki/INTERCAL#Version_Numbers)
compilers (where for example 0.26 < 1.26 < 0.27).

The `subtree` key indicates a directory inside the sources to use instead
of the top level.

## git

The upstream sources are available via a public git repository; the following
keys need to be present:

- `repos` (or `repository`) is a valid argument to the `git clone` command.
- optionally, `branch` to select a branch within the repository.
- optionally, `version` to convert a version string to a tag: the value is
either a single string which is prefixed to the version number, or two
strings separated by space, the first one is prefixed and the second appended.
- optionally, `user` and `password` can be specified to obtain access to the
repository (this is currently not implemented, all repositories must be
accessible without authentication).

A software version can be identified by a generic git commit ID, or by a
version string similar to the one described for the `compare` key, if the
repository offers that as an option.

## download

The upstream sources are released as published versions and downloaded
directly; the following keys need to be present:

- `uri` indicates where to obtain these sources, and can contain the special
symbol `%V` to indicate the version or `%%` to indicate just a percentage
sign (`%`)

TBC - we also need to say how to unpack the sources etc

# Modification definition file <a name="modification"></a>

There can be zero or more modification definition files in the configuration
directory; each file has a name ending in `.mod` and they are processed
in lexycographic order according to the "C" locale (rather than the current
locale, to guarantee consistent ordering). Note that only files are
considered; if the configuration directory contains subdirectories, these
are ignored, but files in there can be referenced by the `.mod` files.

The contents of each modification definition file are an initial part with
format similar to the Upstream definition file described above ("key = value"
pair, possibly with conditional blocks); this initial part ends with a line
containing just dashes and the rest of the file, referred to as "final
part", is interpreted based on information from the initial part.

The following keys are currently understood:

- `version`: the value has the same format as the condition on the
`if version` specification in the Upstream definition file: one or two
strings separated by whitespace, one of the strings starting with `<`
or `<=` and the other starting with `>` or `>=` to indicate a maximum,
minimum or range of versions.  One use of this key is to indicate that
a modification is only necessary up to a particular version, because
for example that modification has been accepted by upstream and is
no longer necessary.  Another use of this key is to identify versions
in which substantial upstream changes make it difficult to specify a
modification which works for every possible version. Specifying this
keyword is essentially equivalent to put the whole `.mod` file in
a conditional.
- `method`; the method used to specify the modification; currently, the
value can be one of: `patch`, indicating that the final part of the file is
in a format suitable for passing as standard input to the "patch" program;
`replace` indicating that one or more files in the upstream must be
completely replaced; the final part of the file contains one or more
lines with format "old-file = new-file", where both are relative paths,
the first relative to the root of the extracted upstream sources; the
second path is relative to the configuration directory; `sed` indicating
a sed-like set of replacements, with the final part of the file
containing likes with format "file-glob: regular-expression = replacement"
(the regular expression can contain spaces and equal signs if they are
quoted with a backslash); the replacement is always done on the whole
file at once.

Other keys are interpreted depending on the value of `method`; there are
currently no other keys for the `replace` and `sed` methods, and the
following for the `patch` method:

- `options`: options to pass to the "patch" program (default: "-Nsp1")
- `list`: extra options to the "patch" program to list what it would do
instead of actually doing it (this is used internally to figure out
what changes; the default currently assumes the "patch" program provided
by most Linux distributions)

If a file is modified by more than one method, these are executed in
the sequence determined by the ordering of the modification definition
files, so for example a `replace` method only makes sense if it appears
first (otherwise it undoes all previous changes).

# Example Configuration directory <a name="example"></a>

Obtaining SQLite sources and replacing btree.c and btreeInt.h with the ones
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

A more complete example can be found in the directory "not-fork.d/sqlite"
which tracks upstream updates from SQLite.

# Not-forking tool <a name="tool"></a>

The `tool` directory contain a script, `not-fork` which runs the not-forking
mechanism on a directory.  Usage is:

not-fork \[OPTIONS\] \[NAME\]...

where the following options are available:

- `-i`INPUT\_DIRECTORY (or `--input=`INPUT\_DIRECTORY)
is a not-forking configuration directory as specified
in this document; default is `not-fork.d` within the current directory
- `-o`OUTPUT\_DIRECTORY (or `--output=`OUTPUT\_DIRECTORY)
is the place where the modified upstream sources will
be stored, and it can be either a directory created by a previous run of
this tool, or a new directory (missing or empty directory); default is
`sources` within the current directory; note that existing sources in
this directory may be overwritten or deleted by the tool
- `-c`CACHE\_DIRECTORY (or `--cache=CACHE\_DIRECTORY`)
is a place used by the program to keep downloads
and working copies; it must be either a new (missing or empty) directory
or a directory created by a orevious run of the tool; default is
`.cache/LumoSQL/not-fork` inside the user's home directory
- `-v`VERSION (or `--version=`VERSION) will retrieve the specified VERSION
of the next NAME (this option must be repeated for each NAME, in the
assumption that different projects have different version numbering)
- `-c`COMMIT\_ID (or `--commit=`COMMIT\_ID) is similar to `-v` but
only works for version control modules which support commit identifiers,
and will retrieve the corresponding commit for the next NAME, whether
or not it has an official version number; this is incompatible with `-v`
- `-q` (or `--query`) completes all necessary downloads but do not
extract the sources and apply modifications, instead it shows some
information about what has been downloaded, including a version number
if available.

If neither VERSION nor COMMIT\_ID is specified, the default is the latest
available version, if it can be determined, or else an error message.
If more than one NAME is specified, VERSION and COMMIT\_ID need to
be provided before each NAME: the assumption is that different
software projects use different version numbers.

If one or more NAMEs are specified, the tool will obtain the upstream
sources as described in INPUT\_DIRECTORY/NAME for each of the NAMEs
specified, and attempt to apply all the required modifications; if that
succeeds, OUTPUT\_DIRECTORY/NAME will contain the modified sources ready
to use; if that fails, an error message will explain the problem and if
possible suggest corrective action (for example, if `patch` determines
that a file has changed too much that it cannot figure out how to apply
a patch supplied, the error message will indicate this and suggest to
obtain a new patch for that version of the sources).

If no NAMEs are specified, the tool, will process all subdirectories
of INPUT\_DIRECTORY. In this special case, any VERSION or COMMIT\_ID
specified will apply to all rather than just the name immediately
following them.

The tool looks for a configuration file located at
`$HOME/.config/LumoSQL/not-fork.conf` to read defaults; if the file exists
and is readable, any non-comment, non-empty lines are processed before
any command-line options with an implicit `--` prepended and with spaces
around the first `=` removed, if present: so for example a file containing:

```
cache = /var/cache/LumoSQL/not-fork
```

would change the default cache from `.cache/LumoSQL/not-fork` in the user's
home directory to the above directory inside `/var/cache`; it can still
be overridden by specifying `-c`/`--cache` on the command line.

The program will refuse to overwrite the output directory if it cannot
determine that it has been created by a previous run and that files have
not been modified since; in this case, delete the output directory
completely, or rename it to something else, and run the program again.
There is currently no option to override this safety feature.

We plan to add logging to the not-forking tool, in which all messages are
written to a log file (under control of configuration), while the subset
of messages selected by the verbosity setting will go to standard output;
this will allow us to increase the amount of information provided and make
it available if there is a processing error; however in the current version
this is just planned, and not yet implemented.

