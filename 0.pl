use 5.010;
use strict;
use warnings;
use DDP;
use Data::Dumper;

my @members = 'A'..'Z';
my %members; @members{@members} = ();
my @pairs;
for (1..@members/4) {
	my ($one,$two) = keys %members;
	delete $members{$one};
	delete $members{$two};
	push @pairs, [ $one, $two ];
}

my @list = sort { int(rand 3)-1 } @pairs, keys %members;

if (@list < 2 || (@list == 2) && ((ref \$list[0] eq 'SCALAR') && (ref \$list[1] eq 'REF') || (ref \$list[0] eq 'REF') && (ref \$list[1] eq 'SCALAR'))) { say 'nope'; }
else {
	my %pairs = map { ${$_}[0] => ${$_}[1], ${$_}[1] => ${$_}[0] } grep { ref \$_ eq 'REF' } @list;
	p %pairs;
	my @members = (keys %pairs, grep { ref \$_ eq 'SCALAR' } @list);

	my @res = ();
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
							$drain = $free[rand(scalar @free)];
							delete $free{$drain};
							@free = map {$_} keys %free;
						}
						else
						{
							$drain = $first;
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
	p @res;
}
