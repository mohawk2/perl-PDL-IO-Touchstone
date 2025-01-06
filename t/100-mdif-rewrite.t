use strict;
use warnings;

use PDL;
use PDL::IO::MDIF;
use File::Temp qw/tempfile/;

use Test::More;
use Test::PDL -atol => 1e-6;

my ($fh, $fn) = tempfile();
END {close $fh; unlink $fn};

my $mdf = rmdf('t/test-data/muRata/muRata-GQM-0402.mdf');
wmdf($fn, $mdf);

my $mdf2 = rmdf($fn);

ok(@$mdf == @$mdf2, "count");

for (my $i = 0; $i < @$mdf; $i++)
{
	my ($f1, $m1, $param_type1, $z01, $comments1, $fmt1, $funit1, $orig_f_unit1) = @{ $mdf->[$i]->{_data} };
	my ($f2, $m2, $param_type2, $z02, $comments2, $fmt2, $funit2, $orig_f_unit2) = @{ $mdf2->[$i]->{_data} };

	# These first three just check my code in this test:
	ok($$f1 != $$f2, "f refs are different");
	ok($$m1 != $$m2, "m refs are different");
	ok($$z01 != $$z02, "z0 refs are different");

	is_pdl $f1, $f2, "freqs";
	is_pdl $m1, $m2, "matrix";
	is_pdl $z01, $z02, "z0";

	foreach my $n (qw/param_type comments fmt funit orig_f_unit/)
	{
		ok(eval "qq{\$${n}1} eq qq{\$${n}2}", "$n is correct");
	}
}

done_testing;
