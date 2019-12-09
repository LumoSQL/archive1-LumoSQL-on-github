bin: bld-sqlite/sqlite3

src-sqlite:
	git clone git@github.com:sqlite/sqlite.git sqlite.git
	git -C src-sqlite checkout version-3.30.1

bld-sqlite/sqlite3: src-sqlite
	rm -rf bld-sqlite
	mkdir bld-sqlite
	cd bld-sqlite ; ../src-sqlite/configure ; cd ..
	make -C bld-sqlite
	bld-sqlite/sqlite3 --version
