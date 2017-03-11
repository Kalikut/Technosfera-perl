use 5.010;
use strict;
use warnings;
use DDP;
use Data::Dumper;
use Encode;

sub clone {
    my $orig = shift;
    my $adr_hash = {};
    my $copy = copy($orig, $adr_hash);
    if (exists $adr_hash->{$orig} and not defined $adr_hash->{$orig}) { return undef; }
    return $copy;
}

sub copy {
    my $orig = shift;
    my $adr = shift;
    my $cloned;
    if (ref \$orig eq 'SCALAR') { $cloned = $orig; }
    elsif (ref $orig eq 'ARRAY') {
        if (exists $adr->{$orig}) { return $adr->{$orig}; }
        my $aref = [];
        $adr->{$orig} = $aref;
        for my $elem (@{$orig}) {
            push @{$aref}, copy($elem, $adr);
        }
        $cloned = $aref;
    }
    elsif (ref $orig eq 'HASH') {
        if (exists $adr->{$orig}) { return $adr->{$orig}; }
        my $href = {};
        $adr->{$orig} = $href;
        for my $key (keys %{$orig}) {
            $href->{$key} = copy($orig->{$key}, $adr);
        }
        $cloned = $href;
    }
    else { $cloned = undef; for my $key (keys %{$adr}) { $adr->{$key} = undef; } }
    return $cloned;
};

my $ak = {1 => 'one', 2 => 'two'};
my $bk = [3..5];
$ak->{3} = $bk;
$ak->{4} = $bk;
$ak->{5} = $bk;
$ak->{self} = $ak;
$ak = [ 1, 2, 3, { a => 1, b => 2, c => [ qw/x y z/, sub {} ] } ];

p $ak;

my $ck = clone($ak);

p $ck;
