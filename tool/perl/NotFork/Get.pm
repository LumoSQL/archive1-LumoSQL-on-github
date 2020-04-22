package NotFork::Get;

use strict;
require Exporter;
use Carp;
use Digest::SHA qw(sha512_hex);
use File::Path qw(make_path remove_tree);
use File::Find qw(find);
use File::Copy qw(cp);
use Fcntl qw(:flock :seek);
use IO::Handle;

our @EXPORT_OK = qw(
    set_input
    set_cache
    set_output
    all_names
    load_file
    list_files
);
our @EXPORT = @EXPORT_OK;
our @ISA = qw(Exporter);

my $input = 'notforking';
my $output = 'sources';
my $cache = undef;

my (%checked_input, %checked_output, %checked_cache);

sub _hash {
    my ($index) = @_;
    return substr(sha512_hex($index), 42, 32);
}

sub set_input {
    @_ == 1 or croak "Usage: NotFork::Get::set_input(DIR)";
    ($input) = @_;
    # we'll check it when we use it
}

sub set_cache {
    @_ == 1 or croak "Usage: NotFork::Get::set_cache(DIR)";
    ($cache) = @_;
    # we'll check it when we use it
}

sub set_output {
    @_ == 1 or croak "Usage: NotFork::Get::set_output(DIR)";
    ($output) = @_;
    # we'll check it when we use it
}

sub all_names {
    _check_input_dir();
    opendir(my $dh, $input) or die "$input: $!\n";
    my @names = sort grep { $_ !~ /^\./ } readdir $dh;
    closedir $dh;
    @names;
}

sub _check_input_dir {
    exists $checked_input{$input} and return;
    $checked_input{$input} = undef;
    _check_dir($input, 0, 0);
    # do we want to check all entries?
}

sub _check_input_name {
    my ($name) = @_;
    _check_input_dir($input);
    _check_dir("$input/$name", 0, 0);
    _check_file("$input/$name/upstream.conf", 0, 0);
}

sub _check_output_dir {
    _check_input_dir();
    exists $checked_output{$output} and return;
    $checked_output{$output} = undef;
    _check_dir($output, 1, 1) or return;
    opendir(OD, $output) or die "$output: $!\n";
    for my $ent (readdir OD) {
	$ent =~ /^\./ and next;
	lstat "$output/$ent" or die "$output/$ent: $!\n";
	-d _ or die "$output/$ent: not a directory\n";
	-d "$input/$ent"
	    or die "$output/$ent: cannot find matching input $input/$ent\n";
	# XXX anything else to check in the output directory...
    }
    closedir OD;
}

sub _check_cache_dir {
    _check_input_dir();
    if (! defined $cache) {
	my $hd = $ENV{HOME} or die "Cannot figure out your \$HOME\n";
	$cache = "$hd/.cache/LumoSQL/notfork";
    }
    exists $checked_cache{$cache} and return;
    $checked_cache{$cache} = undef;
    _check_dir($cache, 1, 1) or return;
    opendir(OD, $cache) or die "$cache: $!\n";
    for my $ent (readdir OD) {
	$ent eq '.' || $ent eq '..' and next;
	$ent eq '.lock' and next;
	my $ed = "$cache/$ent";
	lstat $ed or die "$ed: $!\n";
	-d _ or die "$ed: not a directory\n";
	my $uf = "$ed/index";
	lstat $uf or die "$uf: $!\n";
	-f _ or die "$uf: not a regular file\n";
	open(my $fh, '<', $uf) or die "$uf: $!\n";
	my $index = <$fh>;
	close $fh;
	defined $index or die "$uf: empty file?\n";
	# should really check if it's the correct index...
	# XXX anything else to check in the cache directory...
    }
    closedir OD;
}

sub _check_file {
    my ($file, $missing_ok, $writable) = @_;
    if (! stat $file) {
	$missing_ok and return 0;
	die "$file: $!\n";
    }
    -f _ or die "$file: not a regular file\n";
    -r _ or die "$file: not readable\n";
    if ($writable) {
	-w _ or die "$file: not writable\n";
    }
    return 1;
}

sub _check_dir {
    my ($dir, $missing_ok, $writable) = @_;
    if (! stat $dir) {
	$missing_ok and return 0;
	die "$dir: $!\n";
    }
    -d _ or die "$dir: not a directory\n";
    -r _ or die "$dir: not readable\n";
    -x _ or die "$dir: not searchable\n";
    if ($writable) {
	-w _ or die "$dir: not writable\n";
    }
    return 1;
}

sub new {
    @_ == 4 or croak "Usage: new NotFork::Get(NAME, VERSION, COMMIT_ID)";
    my ($class, $name, $version, $commit) = @_;
    _check_input_name($name);
    my $obj = bless {
	name    => $name,
	verbose => 0,
    }, $class;
    defined $version and $obj->version($version);
    defined $commit and $obj->commit($commit);
    $obj->_load_config;
    $obj;
}

sub DESTROY {
    my ($obj) = @_;
    $obj->{vcslock} and _unlock($obj->{vcslock});
}

my %if_conditions = (
    version => ['version', \&_cmp_version, 'compare'],
);

my %required_keys_upstream = (
    vcs => \&_load_vcs,
);

my %required_keys_mod = (
    method => \&_load_method,
);

my %condition_keys_mod = (
    version => \&_check_version, # XXX need to write this sub
);

sub _load_config {
    my ($obj) = @_;
    my $dn = "$input/$obj->{name}";
    $obj->{directory} = $dn;
    $obj->_load_upstream("$dn/upstream.conf");
    opendir (my $dh, $dn) or die "$dn: $!\n";
    my @files = sort grep { ! /^\./ && /\.mod$/i } readdir $dh;
    closedir $dh;
    $obj->{mod} = [];
    for my $fn (@files) {
	$obj->_load_modfile("$dn/$fn");
    }
    $obj;
}

sub load_file {
    @_ == 4 || @_ == 5
	or croak "Usage: load_file(HANDLE, NAME, DATA, RESULT_HASH [, OPTIONS])";
    my ($fh, $sf, $data, $hash, $options) = @_;
    my $if = undef;
    my $ifval = 1;
    my $stop = defined $options ? $options->{stop} : undef;
    while (defined (my $line = <$fh>)) {
	defined $stop && $stop->($line) and last;
	$line =~ /^\s*$/ and next;
	$line =~ /^\s*#/ and next;
	chomp $line;
	if ($line =~ s/\\$//) {
	    my $nl = <$fh>;
	    if (defined $nl) {
		$line .= $nl;
		redo;
	    }
	}
	$line =~ s/^\s*(\S+)\s*// or die "$sf.$.: Invalid line format: [$line]\n";
	my $kw = lc($1);
	if ($kw eq 'if') {
	    $line =~ s/^(\S+)\s*// or die "$sf.$.: Invalid line format for $kw: [$line]\n";
	    my $item = lc($1);
	    exists $if_conditions{$item} or die "$sf.$.: Invalid item ($item)\n";
	    my ($element, $compare, $override) = @{$if_conditions{$item}};
	    my $have = $data->{$element};
	    if (defined $override && exists $hash->{$override}) {
		$override = $hash->{$override};
	    } else {
		$override = undef;
	    }
	    $ifval = 1;
	    while ($line ne '') {
		$line =~ s/^(<=|<|=|>=|>)\s*(\S+)\s*//
		    or die "$sf.$.: Invalid operand for $kw $item: [$line]\n";
		my ($op, $val) = ($1, $2);
		$compare->($op, $have, $val, $override) or $ifval = 0;
	    }
	    $if = 0;
	} elsif ($kw eq 'else') {
	    defined $if or die "$sf.$.: $kw outside conditional\n";
	    $if and die "$sf.$.: duplicate $kw (lines $if and $.)\n";
	    $ifval = ! $ifval;
	    $if = $.;
	} elsif ($kw eq 'endif') {
	    $if or die "$sf.$.: $kw outside conditional\n";
	    $if = undef;
	    $ifval = 1;
	} elsif ($ifval) {
	    $line =~ s/^=\s*// or die "$sf.$.: Invalid line format for $kw: [$line]\n";
	    $hash->{$kw} = $line;
	}
    }
    defined $options or return 1;
    if (exists $options->{condition}) {
	my $condition = $options->{condition};
	for my $ck (keys %$condition) {
	    exists $hash->{$ck} or next;
	    my $code = $condition->{$ck};
	    $code->($data, $hash->{$ck}, $hash, $sf) or return 0;
	}
    }
    if (exists $options->{required}) {
	my $required = $options->{required};
	for my $rq (keys %$required) {
	    exists $hash->{$rq} or die "$sf: required key $rq not provided\n";
	    my $code = $required->{$rq};
	    defined $code && $code->($data, $hash->{$rq}, $hash, $sf, $fh);
	}
    }
    1;
}

sub _load_upstream {
    my ($obj, $sf) = @_;
    open (my $fh, '<', $sf) or die "$sf: $!\n";
    my %kw;
    load_file($fh, $sf, $obj, \%kw, { required => \%required_keys_upstream });
    close $fh;
    $obj->{kw} = \%kw;
}

sub _load_modfile {
    my ($obj, $mf) = @_;
    open (my $fh, '<', $mf) or die "$mf: $!\n";
    my %kw = ();
    my $keep = load_file($fh, $mf, $obj, \%kw, {
	required => \%required_keys_mod,
	condition => \%condition_keys_mod,
	stop => sub { $_[0] =~ /^-+$/ },
    });
    close $fh;
    $keep and push @{$obj->{mod}}, $kw{method};
}

sub _load_vcs {
    my ($data, $name, $hash, $sf, $fh) = @_;
    my $module = ucfirst(lc($name));
    eval "require NotFork::VCS::$module";
    $@ and die "Cannot load VCS($name): $@";
    my $vcsobj = "NotFork::VCS::$module"->new($data->{name}, $hash);
    $@ and die "$sf: $@";
    exists $data->{verbose} and $vcsobj->verbose($data->{verbose});
    $data->{vcs} = $vcsobj;
    $data->{cache_index} = $vcsobj->cache_index;
    $data->{hash} = _hash($data->{cache_index});
    delete $data->{has_data};
}

sub _load_method {
    my ($data, $name, $hash, $mf, $fh) = @_;
    my $module = ucfirst(lc($name));
    eval "require NotFork::Method::$module";
    $@ and die "Cannot load Method($name): $@";
    my $mobj = "NotFork::Method::$module"->new($data->{name}, $data->{directory}, $hash);
    $@ and die "$mf: $@";
    $mobj->load_data($mf, $fh);
    $hash->{method} = $mobj;
}

# determine if version is within range
sub _cmp_version {
    my ($op, $have, $val, $override) = @_;
    # if no version was requested, it means latest
    if (! defined $have) {
	$op eq '>' || $op eq '>=' and return 1;
	return 0;
    }
    # otherwise convert version number and compare
    my $convert = _convert_function($override);
    my $ch = $convert->($have);
    my $cv = $convert->($val);
    $op eq '=' and return $ch eq $cv;
    $op eq '>' and return $ch gt $cv;
    $op eq '>=' and return $ch ge $cv;
    $op eq '<' and return $ch lt $cv;
    $op eq '<=' and return $ch le $cv;
    # why did we end up here?
    undef;
}

my %convert_version = (
    version => \&_convert_version,
);

sub _convert_function {
    my ($override) = @_;
    defined $override or return $convert_version{'version'};
    exists $convert_version{$override} and return $convert_version{$override};
    die "Invalid version comparison: $override\n";
}

sub _convert_version {
    my $vn = lc($_[0]);
    my $suffix = '';
    if ($vn =~ s/-alpha$//) {
	$suffix = 'a';
    } elsif ($vn =~ s/-beta$//) {
	$suffix = 'b';
    } else {
	$suffix = 'c';
    }
    $vn =~ s((\d+)){sprintf "%015d", $1}ge;
    $vn . $suffix;
}

sub verbose {
    @_ == 1 || @_ == 2 or croak "Usage: NOTFORK->verbose [(VERBOSE?)]";
    my $obj = shift;
    @_ or return $obj->{verbose};
    $obj->{verbose} = shift(@_) || 0;
    exists $obj->{vcs} and $obj->{vcs}->verbose($obj->{verbose});
    $obj;
}

sub version {
    @_ == 1 || @_ == 2 or croak "Usage: NOTFORK->version [(VERSION)]";
    my $obj = shift;
    @_ or return $obj->{version};
    $obj->{version} = shift;
    delete $obj->{commit};
    $obj;
}

sub commit {
    @_ == 1 || @_ == 2 or croak "Usage: NOTFORK->commit [(COMMIT)]";
    my $obj = shift;
    @_ or return $obj->{commit};
    $obj->{commit} = shift;
    delete $obj->{version};
    $obj;
}

sub _lock {
    my ($mode, $file, $name) = @_;
    open (my $fh, $mode, $file) or die "$file: $!\n";
    if (! flock $fh, LOCK_EX|LOCK_NB) {
	print STDERR "Waiting for lock on $name...";
	flock $fh, LOCK_EX or die " $file: $!\n";
	print STDERR "OK\n";
    }
    $fh;
}

sub _unlock {
    my ($fh) = @_;
    flush $fh;
    flock $fh, LOCK_UN;
    close $fh;
}

sub get {
    @_ == 1 or croak "Usage: NOTFORK->get";
    my ($obj) = @_;
    my $vcs = $obj->{vcs};
    _check_cache_dir();
    make_path($cache, { verbose => 0, mode => 0700 });
    my $clfh = _lock('>>', "$cache/.lock", 'cache directory');
    my $cd = $obj->{cache} = "$cache/$obj->{hash}";
    my $vlfh;
    if (-d $cd) {
	$vlfh = _lock('<', "$cd/index", "cache for $obj->{cache_index}");
	my $index = <$vlfh>;
	defined $index or die "Missing index for cache $cd\n";
	chomp $index;
	$index eq $vcs->cache_index
	    or die "Invalid cache directory $cd\n";
    } else {
	make_path($cd, { verbose => 0, mode => 0700 });
	# the next _lock() is the only thing which can create the index file,
	# and we are inside another lock, so we can safely use ">" and we
	# know we aren't going to truncate the file created by somebody else
	$vlfh = _lock('>', "$cd/index", "cache for $obj->{cache_index}");
	print $vlfh "$obj->{cache_index}\n" or die "$cd/index $!\n";
    }
    _unlock($clfh);
    # somebody else could lock the cache directory at this point, but
    # we keep the lock on our bit until we've done the VCS part; there
    # is no danger of deadlock if everybody uses this subroutine to
    # do the locking or make sure to do things in the right order
    $obj->{vcslock} = $vlfh;
    my $top = "$cd/vcs";
    $obj->{vcsbase} = $top;
    $vcs->get($top);
    $obj->{has_data} = 1;
    if (defined $obj->{version}) {
	$vcs->set_version($obj->{version});
    } elsif (defined $obj->{commit}) {
	$vcs->set_commit($obj->{commit});
    } elsif (defined (my $lv = $obj->last_version)) {
	$vcs->set_version($lv);
    }
    my $nv = $vcs->version;
    defined $nv and $obj->{version} = $nv;
    $obj;
}

sub all_versions {
    @_ == 1 or croak "Usage: NOTFORK->all_versions";
    my ($obj) = @_;
    exists $obj->{has_data} or croak "Need to call get() before all_versions()";
    my $convert = _convert_function($obj->{kw}{compare});
    sort { $convert->($a) cmp $convert->($b) } $obj->{vcs}->all_versions;
}

sub last_version {
    @_ == 1 or croak "Usage: NOTFORK->last_version";
    my ($obj) = @_;
    exists $obj->{has_data} or croak "Need to call get() before last_version()";
    my @vers = $obj->all_versions;
    @vers or return undef;
    $vers[-1];
}

sub info {
    @_ == 2 or croak "Usage: NOTFORK->info(FILEHANDLE)";
    my ($obj, $fh) = @_;
    exists $obj->{has_data} or croak "Need to call get() before info()";
    $obj->{vcs}->info($fh);
    $obj;
}

sub install {
    @_ == 1 or croak "Usage: NOTFORK->install";
    my ($obj) = @_;
    exists $obj->{has_data} or croak "Need to call get() before install()";
    my $verbose = $obj->{verbose};
    my %filelist = ();
    _make_filelist($obj, \%filelist);
    my %oldlist = ();
    my $index = "$output/.index";
    make_path($index, { verbose => 0, mode => 0700 });
    my $dest = "$output/$obj->{name}";
    $verbose and print "Installing $obj->{name} into $dest\n";
    my $destlist = "$index/$obj->{name}";
    my $lock = _lock('>', "$index/.lock.$obj->{name}", "output directory for $obj->{name}");
    if (stat $dest) {
	$verbose and print "Checking existing output directory $dest\n";
	-d _ or die "$dest exists but it is not a directory\n";
	opendir(my $dh, $dest) or die "$dest: $!\n";
	my $has_entries = 0;
	while (defined (my $ent = readdir $dh)) {
	    $ent eq '.' || $ent eq '..' and next;
	    $has_entries = 1;
	    last;
	}
	closedir $dh;
	if ($has_entries) {
	    # we need to verify that what we put in here wasn't changed,
	    # otherwise we refuse to overwrite it; also, any new files
	    # from sources must not overwrite existing files which we
	    # didn't know about; if necessary, people can delete these
	    # files and retry.
	    _load_filelist($destlist, \%oldlist);
	    my $ok = 1;
	    for my $ofp (keys %oldlist) {
		lstat "$dest/$ofp" or next;
		my ($_src, $type, $size, $data) = @{$oldlist{$ofp}};
		if ($type eq 'f') {
		    # file is equal if size and hash matches
		    _file_type() eq 'f'
			&& $size == (lstat _)[7]
			    && $data eq _filehash("$dest/$ofp", '')
				and next;
		} elsif (_file_type() eq 'l') {
		    # symlink is equal if target matches
		    my $rl = readlink("$dest/$ofp");
		    defined $rl && $rl eq $data and next;
		}
		# file did not match...
		warn "Will not overwrite or delete $dest\n";
		$ok = 0;
	    }
	    $ok or exit 1;
	}
    }
    # OK, either they passed us a new directory, or they passed us something
    # which we created and they didn't modify except for building objects;
    my $vcs = $obj->{vcs};
    # apply modifications as requested in a temporary cache area
    if (exists $obj->{mod}) {
	$verbose and print "Applying source modifications\n";
	my $cd = "$obj->{cache}/mods";
	-d $cd and remove_tree($cd);
	make_path($cd);
	for my $mobj (@{$obj->{mod}}) {
	    $mobj->apply($obj->{vcsbase}, $cd, sub {
		my ($path, $newdata) = @_;
		_store_file(\%filelist, $path, $newdata);
	    });
	}
    }
    # We can now copy the files to the output directory; if the hash and size
    # hasn't changed we don't copy them though, so a "make" doesn't need to
    # rebuild everything unless the user wants it to
    # Before copying we rename the old file list if it was present, and
    # we write the new one as a temporary file: if the operation gets
    # interrupted it may be possible to continue (if not, delete the whole
    # output directory and recreate it)
    rename ($destlist, "$destlist.old");
    unlink $destlist; # in case the above rename failed
    _write_filelist("$destlist.new", \%filelist);
    $verbose and print "Copying files...\n";
COPY_FILE:
    for my $fp (sort keys %filelist) {
	my ($src, $type, $size, $data) = @{$filelist{$fp}};
	# if file was in the old list, use that information to decide whether
	# to copy it again; and delete it from the old list so at the end
	# anything left in there will be deleted
	if (exists $oldlist{$fp}) {
	    my ($osrc, $otype, $osize, $odata) = @{delete $oldlist{$fp}};
	    if ($otype eq $type && $osize == $size && $odata eq $data) {
		$verbose && $verbose > 1 and print "==== $fp\n";
		next COPY_FILE;
	    }
	}
	# otherwise, if file is already in the output directory check if it
	# we need to copy it or use what we find; this is only possible if
	# this used to be a generated file and now is in the repository, and
	# we may decide in future that we abort the copy if it differs
	my $dp = "$dest/$fp";
	if (lstat $dp) {
	    if ($type eq 'f') {
		-f _ && (lstat _)[7] == $size && _filehash($src, '') eq $data
		    and next COPY_FILE;
	    } elsif (-l _) {
		my $rl = readlink($dp);
		defined $rl && $rl eq $data
		    and next COPY_FILE;
	    }
	    $verbose and print "(rm) $fp\n";
	    unlink $dp;
	}
	# copy this file
	my $dir = '.';
	if ($dp =~ m!^(.*)/[^/]*$!) {
	    $dir = $1;
	    make_path($dir, { verbose => 0, mode => 0755 });
	}
	if ($type eq 'f') {
	    $verbose and print "(cp) $fp\n";
	    cp($src, $dp) or die "copy($src, $dp): $!\n";
	} else {
	    $verbose and print "(ln) $fp\n";
	    symlink($data, $dp);
	}
    }
    # delete anything in old filelist but not in new; we've already deleted
    # the keys corresponding to anything we've replaced so what's left in
    # %oldlist can go
    for my $fp (keys %oldlist) {
	my $dp = "$dest/$fp";
	$verbose and print "(rm) $fp\n";
	unlink $dp;
    }
    # all done... rename new filelist and delete old
    rename ("$destlist.new", $destlist) or die "rename($destlist.new, $destlist): $!\n";
    unlink "$destlist.old";
    $verbose and print "Copy complete to $dest\n";
    _unlock($lock);
    $obj;
}

sub _write_filelist {
    my ($fn, $list) = @_;
    open (my $fh, '>', $fn) or die "$fn: $!\n";
    for my $fp (sort keys %$list) {
	my ($src, $type, $size, $data) = @{$list->{$fp}};
	print $fh "$type $size $fp\0$data\0" or die "$fn: $!\n";
    }
    close $fh or die "$fn: $!\n";
}

sub _load_filelist {
    my ($fn, $list) = @_;
    open (my $fh, '<', $fn) or die "$fn: $!\n";
    local $/ = "\0";
    while (defined (my $fp = <$fh>)) {
	chomp $fp;
	$fp =~ s/^([fl])\s(\d+)\s// or die "$fn: Invalid file format (line=$fp)\n";
	my ($type, $size) = ($1, $2);
	my $data = <$fh>;
	defined $data or die "$fn: Invalid file format (missing file data)\n";
	chomp $data;
	$list->{$fp} = [undef, $type, $size, $data];
    }
    close $fh;
}

# called after executing a stat or (better) lstat
sub _file_type {
    -l _ and return 'l';
    -f _ and return 'f';
    -d _ and return 'd';
    0;
}

# calculates hash of a file, returns undef (or $defhash) if there is
# an error but sets $@ in case we want to print a message
sub _filehash {
    my ($path, $defhash) = @_;
    eval {
	open (my $fh, '<', $path) or die "$path: $!\n";
	my $sha = Digest::SHA->new(512);;
	$sha->addfile($fh);
	close $fh;
	$defhash = $sha->hexdigest;
    };
    $defhash;
}

# make a file list from the cache directory
sub _make_filelist {
    my ($obj, $filelist) = @_;
    my $vcs = $obj->{vcs};
    $vcs->list_files(sub { _store_file($filelist, @_); });
}

# helper function for a VCS to list files using "find"; if all files to be
# found are inside $base then their list_files can just call this one
# with ($base, \@dir_exclude, \@file_exclude, $callback)
sub list_files {
    @_ == 4 or croak "Usage: list_files(DIR, DIR_EXCLUDE, FILE_EXCLUDE, CALLBACK)";
    my ($base, $dir_excl, $file_excl, $code) = @_;
    my $bl = length $base;
    find({
	preprocess => sub {
	    scalar(@$dir_excl) || scalar(@$file_excl) or return @_;
	    my @result = ();
	NAME:
	    for my $name (@_) {
		if ($name ne '.' && $name ne '..') {
		    my $fp = "$File::Find::dir/$name";
		    lstat $fp or next;
		    my $excl = -d _ ? $dir_excl : $file_excl;
		    substr($fp, 0, $bl) eq $base
			&& substr($fp, $bl, 1) eq '/'
			    and substr($fp, 0, $bl + 1) = '';
		    for my $xp (@$excl) {
			if (ref($xp) eq 'Regexp') {
			    $fp =~ $xp and next NAME;
			} else {
			    $xp eq $fp and next NAME;
			}
		    }
		}
		push @result, $name;
	    }
	    @result;
	},
	wanted => sub {
	    my $name = $File::Find::name;
	    my $idx = $name;
	    substr($idx, 0, $bl) eq $base
		&& substr($idx, $bl, 1) eq '/'
		    and substr($idx, 0, $bl + 1) = '';
	    $code->($idx, $name);
	},
	no_chdir => 1,
    }, $base);
}

sub _store_file {
    my ($filelist, $idx, $name) = @_;
    lstat($name) or return; # Hmmm
    my $type = _file_type();
    if (! $type) {
	warn "Ignoring $name, not a regular file or symlink\n";
	return;
    }
    $type eq 'd' and return;
    my $size = (lstat _)[7];
    my $data;
    if ($type eq 'f') {
	$data = _filehash($name);
	defined $data or die $@;
    } else {
	$data = readlink($name);
	defined $data or die "$name: $!\n";
    }
    $filelist->{$idx} = [$name, $type, $size, $data];
}

1
