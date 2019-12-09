.PHONY:
bin: bld-sqlite-3.30.1/sqlite3 bld-LMDB_0.9.16/sqlite3

.PHONY:
clean:
	rm -rf bld-* version.txt

src-sqlite:
	git clone git@github.com:sqlite/sqlite.git sqlite.git

src-%:
	# git@github.com:LMDB/sqlightning.git is an alternative to .
	git clone --branch $* . $@

src-lmdb:
	test -d src-lmdb || git clone git@github.com:LMDB/lmdb.git src-lmdb

bld-sqlite-%/sqlite3: src-sqlite
	git -C src-sqlite checkout version-$*
	rm -rf bld-sqlite-$* && mkdir bld-sqlite-$*
	cd bld-sqlite-$* && ../src-sqlite/configure && cd ..
	make -C bld-sqlite-$*
	$@ --version

bld-LMDB_%/sqlite3: src-lmdb src-mdb
	git -C src-lmdb checkout LMDB_$*
	rm -rf bld-LMDB_$* && mkdir bld-LMDB_$*
	cd bld-LMDB_$* && ../src-mdb/configure \
		CFLAGS="-I../src-lmdb/libraries/liblmdb" && cd ..
	make -C bld-LMDB_$* sqlite3.h
	printf '#undef SQLITE_SOURCE_ID\n' > version.txt
	printf '#define SQLITE_SOURCE_ID "%s %-12s %s"\n' \
		"$$(git -C src-mdb rev-parse --short HEAD)" \
		"$$(git -C src-lmdb describe --tags)" \
		"$$(git -C src-lmdb rev-parse --short HEAD)" \
		>> version.txt
	sed -i '/^#define SQLITE_SOURCE_ID/rversion.txt' \
		bld-LMDB_$*/sqlite3.h
	rm -f version.txt
	make -C bld-LMDB_$*
	$@ --version
