package NotFork::Method::Patch;

use strict;
use Carp;
use Fcntl ':seek';
use Text::ParseWords qw(shellwords);

sub new {
    @_ == 4 or croak "Usage: Notfork::Method::Replace->new(NAME, SRCDIR, OPTIONS)";
    my ($class, $name, $srcdir, $options) = @_;
    # if they've specified options to the "patch" program, use them; otherwise
    # use the defaults
    my $patch = '-tNsp1';
    exists $options->{options} and $patch = $options->{options};
    my @patch = shellwords($patch);
    # additional options to "patch" to get a list of files only
    my $list = '--dry-run --read-only=ignore --verbose';
    exists $options->{list} and $list = $options->{list};
    my @list = shellwords($list);
    bless {
	name    => $name,
	srcdir  => $srcdir,
	patch   => \@patch,
	list    => \@list,
    }, $class;
}

# this is called after NotFork::Get has read the first part of a modification
# file; for us, the rest is something to pass unchanged to "patch"; we do
# not load it in memory, rather we remember where it comes from
sub load_data {
    @_ == 3 or croak "Usage: REPLACE->load_data(FILENAME, FILEHANDLE)";
    my ($obj, $fn, $fh) = @_;
    my $pos = tell $fh;
    defined $pos or die "$fn: $!\n";
    push @{$obj->{mods}}, [$fn, $pos];
    $obj;
}

# this is called to apply a patch; we copy the file from the original
# (VCS dir) into a cache directory then apply the patch there
sub apply {
    @_ == 4 or croak "Usage: REPLACE->apply(VCS_DIR, REPLACE_CALLBACK, EDIT_CALLBACK)";
    my ($obj, $vcs, $r_call, $e_call) = @_;
    my $src = $obj->{srcdir};
    for my $mods (@{$obj->{mods}}) {
	my ($fn, $pos) = @$mods;
	open(my $fh, '<', $fn) or die "$fn: $!\n";
	# first figure out what files will change...
	my %files = ();
	my $th = _run_patch($obj, $vcs, $fn, $fh, $pos, 1, 'patch', 'list');
	while (defined (my $po = <$th>)) {
	    $po =~ s/^\s*checking\s+file\s+// or next;
	    chomp $po;
	    $files{$po} = undef;
	}
	close $th;
	# ask to make a copy so we can patch
	my $copy = $e_call->(keys %files);
	# patch them...
	_run_patch($obj, $copy, $fn, $fh, $pos, 0, 'patch');
	# and tell callback what we've changed
	for my $f (sort keys %files) {
	    $r_call->($f, "$copy/$f");
	}
    }
}

# run 'patch' on the source
sub _run_patch {
    my ($obj, $vcs, $srcn, $srch, $srcp, $pipe, @args) = @_;
    my @patch = ('patch', map { @{$obj->{$_}} } @args);
    my $pid = open(my $ph, '-|');
    defined $pid or die "patch: $!\n";
    if ($pid == 0) {
	chdir $vcs or die "$vcs: $!\n";
	seek $srch, $srcp, SEEK_SET or die "$srcn: $!\n";
	open(STDIN, '<&=', $srch);
	exec @patch;
	die "Can't exec $patch[0]\n";
    } elsif ($pipe) {
	return $ph;
    }
    # copy output to STDOUT
    while (defined (my $pl = <$ph>)) {
	print $pl;
    }
}

1
