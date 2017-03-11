package Anagram;

use 5.010;
use strict;
use warnings;
use Encode;

=encoding UTF8

=head1 SYNOPSIS

Поиск анаграмм

=head1 anagram($arrayref)

Функцию поиска всех множеств анаграмм по словарю.

Входные данные для функции: ссылка на массив - каждый элемент которого - слово на русском языке в кодировке utf8

Выходные данные: Ссылка на хеш множеств анаграмм.

Ключ - первое встретившееся в словаре слово из множества
Значение - ссылка на массив, каждый элемент которого, слово из множества. Массив должен быть отсортирован по возрастанию.

Множества из одного элемента не должны попасть в результат.

Все слова должны быть приведены к нижнему регистру.
В результирующем множестве каждое слово должно встречаться только один раз.
Например

anagram(['пятак', 'ЛиСток', 'пятка', 'стул', 'ПяТаК', 'слиток', 'тяпка', 'столик', 'слиток'])

должен вернуть ссылку на хеш


{
    'пятак'  => ['пятак', 'пятка', 'тяпка'],
    'листок' => ['листок', 'слиток', 'столик'],
}

=cut

sub same {
    my $key = shift;
    my $word = shift;
    my @char;
    if (length($key) != length($word)) { return 0; }
    for my $iter (0..length($key)-1) { $char[ord(substr($key, $iter, 1))]++; } 
    for my $iter (0..length($word)-1) { unless ($char[ord(substr($word, $iter, 1))]--) { return 0; } } 
    return 1;
}

sub anagram {
    my $words_list = shift;
    my %result;
    my @words = map { encode('utf8', lc decode('utf8', $_)) } @{$words_list};
    if (not @words) { return \%result; }
    my %words;
CYCLE:
    for my $cur_word (@words) {
        if (exists $words{$cur_word}) { next; }
        $words{$cur_word} = undef;
        for my $key (keys %result) {
            if (same($key, $cur_word)) { push @{$result{$key}}, $cur_word; next CYCLE; }
        }
        $result{$cur_word} = [ $cur_word ];
    }
    for my $key (keys %result) {
        if (@{$result{$key}} == 1) { delete $result{$key}; next; }
        $result{$key} = [ sort @{$result{$key}} ];
    }
    return \%result;
}


1;
