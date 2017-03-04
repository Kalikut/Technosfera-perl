package SecretSanta;

use 5.010;
use strict;
use warnings;
use DDP;

sub calculate {
	my @list = @_;
	my @res = ();
	if (@list < 2 || (@list == 2) && ((ref \$list[0] eq 'SCALAR') && (ref \$list[1] eq 'REF') || (ref \$list[0] eq 'REF') && (ref \$list[1] eq 'SCALAR'))) { say 'nope'; }
	else {
		my %pairs = map { ${$_}[0] => ${$_}[1], ${$_}[1] => ${$_}[0] } grep { ref \$_ eq 'REF' } @list;
		my @members = (keys %pairs, grep { ref \$_ eq 'SCALAR' } @list);
	
		@res = ();
		while (@res != @members) {
			@res = ();
			my %free = map {$_ => undef} @members;
			my @free = map {$_} keys %free;
			my %from = ();
			my %to = ();
			my $source = $free[rand(scalar @free)];
			my $first = $source;
			
			my $cycle_length = 0;
			my $drain;
			for (1..2*@members) {
				if (scalar @free) {
					$drain = $free[rand(scalar @free)];
					delete $free{$drain};
					@free = map {$_} keys %free;
				}
				else
				{
					$drain = $first;
				}
				unless ($source eq $drain || exists $to{$drain} || (exists $pairs{$source} && $pairs{$source} eq $drain)) {
					unless (exists $from{$drain}) {
						$from{$source} = $drain;
						$to{$drain} = $source;
						$source = $drain;
						++$cycle_length;
					}
					else {
						if ($cycle_length >= 2) {
							$from{$source} = $drain;
							$to{$drain} = $source;
							if (scalar @free) {
								$source = $free[rand(scalar @free)];
								$first = $source;
								@free = map {$_} keys %free;
							}
							else
							{
								$source = $first;
							}
							$cycle_length = 0;
						}
						else
						{
							last;
						}
					}
				}
				else {
					last;
				}
			}
			@res = map {[$_, $from{$_}]} keys %from;
		}
	}
	return @res;
}

1;
