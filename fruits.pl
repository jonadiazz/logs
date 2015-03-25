#!/usr/bin/perl
use Modern::Perl;
use Data::Dumper;

my %fruits = ( apple => 'Tasty',
               orange => 'Round',
               banana => 'Yellow' );

print %fruits;

my @types = keys %fruits;

#say "Just the keys: @types\n";

print Dumper(\%fruits);
