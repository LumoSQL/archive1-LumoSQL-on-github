bin: bld-SQLite-3.30.1 bld-LMDB_0.9.16

clean:
	rm -rf bld-* version.txt

src-sqlite:
	git clone https://github.com/sqlite/sqlite.git src-sqlite

src-%:
	# git@github.com:LMDB/sqlightning.git is an alternative to .
	git clone . $@
	git -C $@ checkout --quiet "$$(git rev-parse --verify $* 2>/dev/null \
		|| git rev-parse origin/$* )"

src-lmdb:
	git clone https://github.com/LMDB/lmdb.git src-lmdb

bld-SQLite-%: src-sqlite
	git -C src-sqlite checkout version-$*
	rm -rf $@ && mkdir $@
	cd $@ && ../src-sqlite/configure && cd ..
	make -C $@
	$@/sqlite3 --version

bld-LMDB_%: src-lmdb src-mdb
	git -C src-lmdb checkout LMDB_$*
	rm -rf $@ && mkdir $@
	cd $@ && ../src-mdb/configure \
		CFLAGS="-I../src-lmdb/libraries/liblmdb" && cd ..
	make -C $@ sqlite3.h
	printf '#undef SQLITE_SOURCE_ID\n' > version.txt
	printf '#define SQLITE_SOURCE_ID "%s %-11s %s"\n' \
		"$$(git -C src-mdb rev-parse --short HEAD)" \
		"$$(git -C src-lmdb describe --tags)" \
		"$$(git -C src-lmdb rev-parse --short HEAD)" \
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

container:
	container1="$$(buildah from ubuntu:18.04)" && \
	buildah run "$$container1" -- /bin/sh -c "apt-get update \
		&& DEBIAN_FRONTEND=noninteractive apt-get install \
			--no-install-recommends --yes $(BUILD_DEPENDENCIES) \
		&& rm -rf /var/lib/apt/lists/*" && \
	buildah config \
		--entrypoint '[ "make", "-C", "/usr/src" ]' \
		--cmd bin \
		"$$container1" && \
	buildah commit --rm "$$container1" make
# To build and run withint a container:
#   make container
#   podman run -v .:/usr/src:Z make
#   podman run -v .:/usr/src:Z make bld-LMDB_0.9.9
#   podman run -v .:/usr/src:Z --interactive --tty --entrypoint=/bin/bash make

.PRECIOUS: bld-LMDB_% bld-SQLite-% src-mdb src-lmdb
.PHONY: clean bin container
