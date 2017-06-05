#!/usr/bin/perl
use strict;
use warnings;
use Data::Dumper;

sub say {print @_,"\n";}


# y %a = ();
# $a{a} = [];
# push @{$a{a}}, "AAA";
# say Dumper(\%a);
my $l;
while($l = <>) { say $l; }
