LMDB_TAG=LMDB_0.9.16

.PHONY:
bin: bld-sqlite/sqlite3 bld-orig/sqlite3 bld-mdb/sqlite3

.PHONY:
clean:
	rm -rf bld-* version.txt

src-sqlite:
	git clone git@github.com:sqlite/sqlite.git sqlite.git
	git -C src-sqlite checkout version-3.30.1

src-%:
	# alternatively use git@github.com:LMDB/sqlightning.git
	git clone --branch $* . $@

src-lmdb:
	test -d src-lmdb || git clone git@github.com:LMDB/lmdb.git src-lmdb
	git -C src-lmdb checkout $(LMDB_TAG)

bld-%/sqlite3: src-%
	rm -rf bld-$* && mkdir bld-$*
	cd bld-$* && ../src-$*/configure && cd ..
	make -C bld-$*
	$@ --version

bld-mdb/sqlite3: src-lmdb src-mdb
	rm -rf bld-mdb && mkdir bld-mdb
	cd bld-mdb && ../src-mdb/configure \
		CFLAGS="-I../src-lmdb/libraries/liblmdb" && cd ..
	make -C bld-mdb sqlite3.h
	printf '#undef SQLITE_SOURCE_ID\n' > version.txt
	printf '#define SQLITE_SOURCE_ID "%s %s %s"\n' \
		"$$(git -C src-mdb rev-parse --short HEAD)" \
		"$$(git -C src-lmdb describe --tags)" \
		"$$(git -C src-lmdb rev-parse --short HEAD)" \
		>> version.txt
	sed -i '/^#define SQLITE_SOURCE_ID/rversion.txt' \
		bld-mdb/sqlite3.h
	rm -f version.txt
	make -C bld-mdb
	$@ --version
