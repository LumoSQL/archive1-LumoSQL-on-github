package NotFork::Method::Replace;

use strict;
use Carp;

sub new {
    @_ == 4 or croak "Usage: Notfork::Method::Replace->new(NAME, SRCDIR, OPTIONS)";
    my ($class, $name, $srcdir, $options) = @_;
    # if we had options for the "replace" method, we'd do something here
    bless {
	name   => $name,
	srcdir => $srcdir,
	mods   => [],
    }, $class;
}

sub load_data {
    @_ == 3 or croak "Usage: REPLACE->load_data(FILENAME, FILEHANDLE)";
    my ($obj, $fn, $fh) = @_;
    my $srcdir = $obj->{srcdir};
    while (defined (my $line = <$fh>)) {
	$line =~ /^\s*$/ and next;
	$line =~ /^\s*#/ and next;
	chomp $line;
	$line =~ /^\s*(\S+)\s*=\s*(\S+)\s*$/ or die "$fn.$.: Invalid line format\n";
	my ($from, $to) = ($1, $2);
	stat "$srcdir/$to" or die "$fn.$.: $to: $!\n";
	-f _ or die "$fn.$.: $to: Not a regular file\n";
	-r _ or die "$fn.$.: $to: Not readable\n";
	push @{$obj->{mods}}, [$from, $to];
    }
    $obj;
}

sub apply {
    @_ == 4 or croak "Usage: REPLACE->apply(VCS_DIR, CACHE_DIR, CALLBACK)";
    my ($obj, $vcs, $cache, $call) = @_;
    my $src = $obj->{srcdir};
    for my $mods (@{$obj->{mods}}) {
	my ($from, $to) = @$mods;
	$call->($from, "$src/$to");
    }
}

1
