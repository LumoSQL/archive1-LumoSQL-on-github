# Top-level Makefile for the LumoSQL project
#
# Copyright 2019 The LumoSQL Authors under the terms contained in LICENSES/MIT
#
# SPDX-License-Identifier: MIT
# SPDX-FileCopyrightText: 2019 The LumoSQL Authors
# SPDX-ArtifactOfProjectName: LumoSQL
# SPDX-FileType: Code
# SPDX-FileComment: Original by Keith Maxwell, 2019 
# 
# /Makefile
#
VERSIONS ?= SQLite-3.7.17 SQLite-3.30.1 LMDB_0.9.9 LMDB_0.9.16

all: $(addprefix bld-,$(VERSIONS))

benchmark: $(addsuffix .html,$(VERSIONS))

clean:
	rm -rf bld-* version.txt *.html

bld-SQLite-%:
	# Build sqlite using https://github.com/sqlite/sqlite, a git mirror of
	# the https://sqlite.org fossil repository
	#
	# A straight clone results in 120MiB of network traffic 20K commits and
	# a .git directory of 112MB
	#
	# Instead we restrict the history to start the day before the first
	# relevant release (3.7.17) to give 63MiB of network traffic,
	# <10K commits and half the disk space.
	#
	# The master branch:
	#
	# - may not include everything in the release branch
	# - does not include all point releases e.g. 3.30.1
	#
	# As a result we also fetch tags matching a wildcard. Fetching all tags
	# is a 30MiB transfer, so is avoided.
	#
	# Cloning in a separate target would result in unnecessary rebuilds if
	# multiple versions of SQLite are required: checking out a specific
	# versions of the SQLite source code results in a change to the
	# modification time for the src-SQLite directory, which in turn results
	# in a rebuild of another version.
	if [ ! -d src-SQLite ] ; then \
		git clone --shallow-since 2013-05-19 \
			https://github.com/sqlite/sqlite.git src-SQLite && \
		git -C src-SQLite fetch origin \
			'refs/tags/version-3.3*:refs/tags/version-3.3*' ; \
	fi
	git -C src-SQLite checkout version-$*
	rm -rf $@ && mkdir $@
	cd $@ && ../src-SQLite/configure && cd ..
	make -C $@
	$@/sqlite3 --version

bld-LMDB_%:
	test -d src-lmdb || \
	git clone https://github.com/LMDB/lmdb.git src-lmdb
	git -C src-lmdb checkout LMDB_$*
	rm -rf $@ && mkdir $@
	cp LICENSES/Apache-2.0.txt $@/LICENSE
	cd $@ && ../lmdb-backend/configure \
		CFLAGS="-I../src-lmdb/libraries/liblmdb" && cd ..
	make -C $@ sqlite3.h
	printf '#undef SQLITE_SOURCE_ID\n' > version.txt
	printf '#define SQLITE_SOURCE_ID "%s %-11s %s"\n' \
		"$$(git -C lmdb-backend rev-parse HEAD)" \
		"$$(git -C src-lmdb describe --tags)" \
		"$$(git -C src-lmdb rev-parse HEAD)" \
		>> version.txt
	sed -i '/^#define SQLITE_SOURCE_ID/rversion.txt' $@/sqlite3.h
	rm -f version.txt
	make -C $@
	$@/sqlite3 --version

%.html: bld-%
	ln -s $</sqlite3
	tclsh tool/speedtest.tcl | tee $@
	rm -f sqlite3 test*.sql clear.sql 2kinit.sql s2k.db s2k.db-lock

# discovered with apt-get build-dep
BUILD_DEPENDENCIES := $(BUILD_DEPENDENCIES) \
	build-essential \
	debhelper \
	autoconf \
	libtool \
	automake \
	chrpath \
	libreadline-dev \
	tcl8.6-dev \
# for cloning over https with git
BUILD_DEPENDENCIES := $(BUILD_DEPENDENCIES) git ca-certificates
# for /usr/bin/tclsh, tcl8.6-dev brings in tcl8.6 which only includes tclsh8.6
BUILD_DEPENDENCIES := $(BUILD_DEPENDENCIES) tcl

.PRECIOUS: bld-LMDB_% bld-SQLite-% src-lmdb
.PHONY: clean bin
