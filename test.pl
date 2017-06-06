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
# while($l = <>) { say $l; }

my %h = (".pl" => [[qr"#.*", ""]],
         ".rb" => sub {
           $_ = shift;
           s/^end$//;
           $_;
         }
        );

sub sanit {
  $_ = shift;
  my $regexps = $h{".rb"};
  $regexps->($_);
}

while($l = <>) { say sanit($l); }
