#!/usr/bin/perl
use v5.14;

my $isInBlock;
my $indent = '';
LINE: while (<>) {
    $isInBlock = !$isInBlock if my $match = /^(\s*)```/;
    next LINE unless $isInBlock;
    $indent = $1 if $match;
    s/$indent//;
    print unless $match;
}
