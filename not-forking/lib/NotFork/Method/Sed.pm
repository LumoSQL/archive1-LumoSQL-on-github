package NotFork::Method::Sed;

use strict;
use Carp;
use Fcntl ':seek';
use File::Find;
use Text::Glob 'glob_to_regex';

sub new {
    @_ == 4 or croak "Usage: Notfork::Method::Sed->new(NAME, SRCDIR, OPTIONS)";
    my ($class, $name, $srcdir, $options) = @_;
    # if we had options for the "sed" method, we'd do something here
    bless {
	name   => $name,
	srcdir => $srcdir,
	mods   => [],
    }, $class;
}

# this is called after NotFork::Get has read the first part of a modification
# file: for us, the rest is a list of "regular-expression = replacement"
# which we parse and save
sub load_data {
    @_ == 3 or croak "Usage: SED->load_data(FILENAME, FILEHANDLE)";
    my ($obj, $fn, $fh) = @_;
    my $srcdir = $obj->{srcdir};
    while (defined (my $line = <$fh>)) {
	$line =~ /^\s*$/ and next;
	$line =~ /^\s*#/ and next;
	chomp $line;
	$line =~ s/^\s+//;
	$line =~ s/^\s*([^:\s]+)\s*:\s*// or die "$fn.$.: Missing file pattern\n";
	my $file_glob = $1;
	my $file_regex = glob_to_regex($file_glob);
	my $pattern = '';
	while ($line =~ s/^(\S*[^\\=\s])//) {
	    $pattern .= $1;
	    $line =~ /^=/ and last;
	    $line =~ s/^\\([\\=\s])// and $pattern .= $1;
	}
	$line =~ s/^\s*=\s*// or die "$fn.$.: Invalid line format\n";
	my $replacement = $line;
	my $text_regex = eval { qr/$pattern/ };
	$@ and die "$fn:$.: Invalid pattern: $@";
	push @{$obj->{mods}}, [$file_regex, $text_regex, $replacement];
	$file_glob =~ m|/| and next;
    }
    $obj;
}

# this is called to apply the substitutions; we read the file in memory, run
# the changes, then write it to a temporary file
sub apply {
    @_ == 4 or croak "Usage: SED->apply(VCS_DIR, REPLACE_CALLBACK, EDIT_CALLBACK)";
    my ($obj, $vcs, $r_call, $e_call) = @_;
    my $src = $obj->{srcdir};
    $vcs =~ m|/$| or $vcs .= '/';
    my $len = length($vcs);
    for my $mods (@{$obj->{mods}}) {
	my ($file_regex, $text_regex, $replacement) = @$mods;
	# figure out which files match
	my @files;
	find({
	    wanted => sub {
		substr($_, 0, $len) eq $vcs and $_ = substr($_, $len);
		if ($_ =~ $file_regex) {
		    push @files, $_;
		    return;
		}
		my $orig = $_;
		s|^.*/|| or return;
		$_ =~ $file_regex and push @files, $orig;
	    },
	    no_chdir => 1,
	}, $vcs);
	# ask to make a copy
	my $copy = $e_call->(@files);
	# and now update them
	local $/ = undef;
	for my $f (@files) {
	    open(my $fh, '+<', "$copy/$f") or die "$f: $!\n";
	    my $data = <$fh>;
	    $data =~ s/$text_regex/$replacement/;
	    seek $fh, 0, SEEK_SET;
	    print $fh $data or die "$f: $!\n";
	    truncate $fh, tell($fh) or die "$f: $!\n";;
	    close $fh or die "$f: $!\n";;
	    $r_call->($f, "$copy/$f");
	}
    }
}

1
