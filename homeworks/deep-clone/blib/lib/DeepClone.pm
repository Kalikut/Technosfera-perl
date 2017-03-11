package DeepClone;

use 5.010;
use strict;
use warnings;

=encoding UTF8

=head1 SYNOPSIS

Клонирование сложных структур данных

=head1 clone($orig)

Функция принимает на вход ссылку на какую либо структуру данных и отдаюет, в качестве результата, ее точную независимую копию.
Это значит, что ни один элемент результирующей структуры, не может ссылаться на элементы исходной, но при этом она должна в точности повторять ее схему.

Входные данные:
* undef
* строка
* число
* ссылка на массив
* ссылка на хеш
Элементами ссылок на массив и хеш, могут быть любые из указанных выше конструкций.
Любые отличные от указанных типы данных -- недопустимы. В этом случае результатом клонирования должен быть undef.

Выходные данные:
* undef
* строка
* число
* ссылка на массив
* ссылка на хеш
Элементами ссылок на массив или хеш, не могут быть ссылки на массивы и хеши исходной структуры данных.

=cut

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


1;
