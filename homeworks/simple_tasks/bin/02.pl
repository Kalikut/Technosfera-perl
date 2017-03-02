#!/usr/bin/perl

use strict;
use warnings;

=encoding UTF8
=head1 SYNOPSYS

Вычисление простых чисел

=head1 run ($x, $y)

Функция вычисления простых чисел в диапазоне [$x, $y].
Пачатает все положительные простые числа в формате "$value\n"
Если простых чисел в указанном диапазоне нет - ничего не печатает.

Примеры: 

run(0, 1) - ничего не печатает.

run(1, 4) - печатает "2\n" и "3\n"

=cut

sub run {
    my ($x, $y) = @_;
    my %hash;
    my $n = ($y-1)/2;
    for my $key_value (1..$n) { $hash { $key_value } = undef; }
    for my $str_iter (1..(sqrt($y)-1)/2) {
        for my $col_iter (1..($n-$str_iter)/(2*$str_iter+1)) {
            delete $hash{$str_iter+$col_iter+2*$str_iter*$col_iter};
        }
    }
    for my $key_value (keys %hash) {
        $hash{ $key_value } = 2*$key_value+1;
    }
    $hash { 0 } = 2 if ($y >= 2);
    for my $hash_value (sort { $a <=> $b } values %hash) {
        print "$hash_value\n" if ($hash_value >= $x);
    }
}

1;
