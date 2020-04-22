package NotFork::VCS::Git;

use strict;
use Carp;
use Git;

sub new {
    @_ == 3 or croak "Usage: new NotFork::VCS::Git(NAME, OPTIONS)";
    my ($class, $name, $options) = @_;
    exists $options->{repos} || exists $options->{repository}
	or die "Missing repository\n";
    my $repos = exists $options->{repos} ? $options->{repos} : $options->{repository};
    my $obj = bless {
	repos   => $repos,
	name    => $name,
	verbose => 0,
    }, $class;
    exists $options->{user} and $obj->{user} = $options->{user};
    exists $options->{password} and $obj->{password} = $options->{password};
    exists $options->{branch} and $obj->{branch} = $options->{branch};
    my ($prefix, $suffix) = ('', '');
    if (exists $options->{version}) {
	($prefix, $suffix) = $options->{version} =~ /^(\S+)\s+(.*)$/
			   ? ($prefix, $suffix)
			   : ($options->{version}, '');
    }
    $obj->{version_prefix} = $prefix;
    $obj->{version_suffix} = $suffix;
    $obj;
}

sub verbose {
    @_ == 1 || @_ == 2 or croak "Usage: GIT->verbose [(VERBOSE?)]";
    my $obj = shift;
    @_ or return $obj->{verbose};
    $obj->{verbose} = shift(@_) || 0;
    $obj;
}

# name used to index elements in download cache; we use the repository URL
sub cache_index {
    @_ == 1 or croak "Usage: GIT->cache_index";
    my ($obj) = @_;
    $obj->{repos};
}

sub get {
    @_ == 2 or croak "Usage: GIT->get(DIR)";
    my ($obj, $dir) = @_;
    my $git;
    my $verbose = $obj->{verbose};
    if (-d "$dir/.git") {
	# assume we have already cloned
	$verbose and print "Updating $obj->{name} in $dir\n";
	$git = Git->repository(WorkingCopy => $dir);
	my $url = $git->command_oneline('config', '--get', 'remote.origin.url');
	$url eq $obj->{repos}
	    or die "Inconsistent cache: $url // $obj->{repos}\n";
	# previous run may have switched to a branch, undo that so the
	# following 'pull' works -- we may want to record if this is needed
	# instead of always running it and ignoring the error if it wasn't
	# necessary
	eval { $git->command(['switch', '-q', '-'], STDERR => 0 ); };
	eval { $git->command('pull'); };
	if ($@) {
	    # Git module is rather buggy...
	    $@ =~ /command returned error: 141/ or die $@;
	}
    } else {
	# need to clone into $dir
	$verbose and print "Cloning $obj->{name}: $obj->{repos} --> $dir\n";
	my @args;
	exists $obj->{branch} and push @args, ('-b', $obj->{branch});
	# XXX user/password?
	Git::command('clone', @args, $obj->{repos}, $dir);
	$git = Git->repository(WorkingCopy => $dir);
    }
    $obj->{git} = $git;
    $obj->{cache} = $dir;
    $obj;
}

# calls a function for each file in the repository
sub list_files {
    @_ == 2 or croak "Usage: GIT->list_files(CALLBACK)";
    my ($obj, $call) = @_;
    exists $obj->{git} or croak "Need to call GIT->get before list_files";
    my $git = $obj->{git};
    my $cache = $obj->{cache};
    my ($fh, $c) = $git->command_output_pipe('ls-files', '-z');
    local $/ = "\0";
    while (defined (my $rl = <$fh>)) {
	chomp $rl;
	$call->($rl, "$cache/$rl");
    }
    $git->command_close_pipe($fh, $c);
}

sub set_version {
    @_ == 2 or croak "Usage: GIT->set_version(VERSION)";
    my ($obj, $version) = @_;
    my $vv = join('', $obj->{version_prefix}, $version, $obj->{version_suffix});
    $obj->{git}->command('checkout', '-q', $vv);
    $obj;
}

sub set_commit {
    @_ == 2 or croak "Usage: GIT->set_commit(COMMIT)";
    my ($obj, $commit) = @_;
    $obj->{git}->command('checkout', '-q', $commit);
    $obj;
}

# list all version numbers
sub all_versions {
    @_ == 1 or croak "Usage: GIT->all_versions";
    my ($obj) = @_;
    exists $obj->{git} or croak "Need to call GIT->get before version";
    my $git = $obj->{git};
    my $prefix = $obj->{version_prefix};
    my $suffix = $obj->{version_suffix};
    my ($fh, $c) = $git->command_output_pipe('show-ref');
    my @versions = ();
    while (defined (my $rl = <$fh>)) {
	$rl =~ /^\S+\s+refs\/tags\/$prefix(.*)$suffix\s*$/ or next;
	push @versions, $1;
    }
    $git->command_close_pipe($fh, $c);
    @versions;
}

# find the current version number; other commands fail for various
# (weird) repository setups so we do this instead; if the second
# argument is present and true, finds an "approximate" version number,
# which is the highest version tag present before the current commit
sub version {
    @_ == 1 || @_ == 2 or croak "Usage: GIT->version [(APPROXIMATE?)]";
    my ($obj, $approx) = @_;
    exists $obj->{git} or croak "Need to call GIT->get before version";
    my $git = $obj->{git};
    my @stat = grep { /\bbranch\.oid\b/ }
	$git->command('status', '--porcelain=2', '--branch');
    @stat or return undef;
    $stat[0] =~ /\s(\S+)$/ or return undef;
    my $oid = $1;
    my $prefix = $obj->{version_prefix};
    my $suffix = $obj->{version_suffix};
    # XXX this does not find approximate version numbers yet
    my ($fh, $c) = $git->command_output_pipe('show-ref', '--dereference');
    my $version = undef;
    while (defined (my $rl = <$fh>)) {
	$rl =~ s/^(\S+)\s+refs\/tags\/$prefix// or next;
	$1 eq $oid or next;
	chomp $rl;
	$rl =~ s/\^.*$//;
	$version = $rl;
    }
    $git->command_close_pipe($fh, $c);
    $version;
}

sub info {
    @_ == 2 or croak "Usage: GIT->info(FILEHANDLE)";
    my ($obj, $fh) = @_;
    my $name = $obj->{name};
    if (exists $obj->{git}) {
	my $git = $obj->{git};
	print $fh "Information for $name:\n";
	print $fh "url = ",
	      $git->command_oneline('config', '--get', 'remote.origin.url'), "\n";
	my $branch = $git->command_oneline('branch', '--show-current');
	defined $branch and print $fh "branch = $branch\n";
	my $version = $obj->version;
	defined $version and print $fh "version = $version\n";
	print $fh "\n";
    } else {
	print $fh "No information for $name\n";
    }
    $obj;
}

1
