use strict;
use warnings;

use PDL;
use PDL::IO::Touchstone qw/rsnp s_to_abcd abcd_to_s /;
use File::Temp qw/tempfile/;

use Test::More;

use Test::PDL -atol => 1e-6;

my $datadir = 't/test-data';

opendir(my $dir, $datadir) or die "$datadir: $!";

my @files = map { "$datadir/$_" } grep { /\.s2p$/i } readdir($dir);
closedir($dir);

@files = grep { !/IDEAL_OPEN/ } @files;

# real examples:
my $S = pdl [
		[
			[0.7163927 + i() * -0.4504119, 0.2836073 + i() *  0.4504119],
			[0.2836073 + i() *  0.4504119, 0.7163927 + i() * -0.4504119]
		]
	];

my $A = pdl [
		[
			[1 + i() * -1.60515694288942e-16, 0.107065112465306 + i() * -158.985376613117],
			[0 + i() *  0                   , 1                 + i() *   -1.60515694288942e-16]
		]
	];

is_pdl s_to_abcd($S, 50), $A, {require_equal_types=>0, test_name=>"(builtin)"};
is_pdl abcd_to_s($A, 50), $S, {require_equal_types=>0, test_name=>"(builtin)"};

foreach my $fn (@files, @ARGV)
{
	my ($f, $m, $param_type, $z0, $comments, $fmt, $funit, $orig_f_unit) = rsnp($fn);

	next unless $param_type eq 'S';

	verify($m, $z0, "$fn (S->ABCD->S):", \&s_to_abcd => \&abcd_to_s);
}

sub verify
{
	my ($m, $z0, $file, $f, $f_inv) = @_;
	my $result = $f->($m, $z0);
	my $inverse = $f_inv->($result, $z0);
	is_pdl $m, $inverse, {require_equal_types=>0, test_name=>$file}; # coming back as cldouble AND cdouble, error?
}

done_testing;
