use strict;
use warnings;

use PDL;
use PDL::IO::Touchstone qw/rsnp s_port_z n_ports/;
use File::Temp qw/tempfile/;

use Test::More;
use Test::PDL -atol => 1e-6;

my $datadir = 't/test-data';

my $S = pdl [
		[
			[0.7163927 + i() * -0.4504119, 0.2836073 + i() *  0.4504119],
			[0.2836073 + i() *  0.4504119, 0.7163927 + i() * -0.4504119]
		],
	];

my $exp = pdl([50.1070651124653-158.985376613117*i()]);
is_pdl s_port_z($S, 50, 1), $exp, "(builtin) Port 1";
is_pdl s_port_z($S, 50, 2), $exp, "(builtin) Port 2";

foreach my $fn (qw(t/test-data/IDEAL_SHORT.s2p))
{
	my ($f, $m, $param_type, $z0, $comments, $fmt, $funit, $orig_f_unit) = rsnp($fn);

	next unless $param_type eq 'S';

	for my $p (1..n_ports($m))
	{
		is_pdl s_port_z($m, $z0, $p), cdouble(50,50), "$fn port-$p";
	}
}

done_testing;
