#!/usr/bin/perl
# Usage ./dupplot.pl file1 file2 >/tmp/data ;
# gnuplot, and type: set title "My Plot";  plot '/tmp/data'
# Author Raimon Grau <raimonster@gmail.com>. Artistic License v2.0

use strict;
use warnings;
use Data::Dumper;
use Digest::MD5;

sub say {print @_,"\n";}

# Normalize lines
sub sanitize {
  $_ = shift;
  s/;.*//;
  s/\)+$/\)/;
  return $_;
}

sub process_file_1 {
  my $f = shift;
  my %h=();
  open(my $fh, "<", $f)
    or die "Can't open < input.txt: $!";

  my $md5;
  while(<$fh>) {
    chomp;
    $_ = sanitize($_);
    next if /^\s*$/;
    $md5 = Digest::MD5::md5_hex($_);
    $h{$md5} = [] unless defined $h{$md5};
    push @{$h{$md5}}, $.;
  }

  close($f);
  return %h;
}


sub process_file_2 {
  my $f = shift;
  my $h1 = shift;

  my @tuples;
  open(my $fh, "<", $f)
    or die "Can't open < input.txt: $!";
  my $md5;
  while(<$fh>){
    chomp;
    $_ = sanitize($_);
    next if /^\s*$/;
    $md5 = Digest::MD5::md5_hex($_);
    for  (@{$h1->{$md5}}) {
      push @tuples, [$. , $_];
    }
  }
  close $f;
  return \@tuples;
}

# Get hashes and line numbers for first file
my %h1 = process_file_1(shift);

# Match hashes with lines from the second file
my $t = process_file_2(shift, \%h1);

# Print lines in a suitable form for gnuplot
for my $tuple (@$t) {
  say $tuple->[0], " " , $tuple->[1] ;
}

# Dumper($t);
# sed -e 's/;.*//' -e 's/ \+/ /' -e'/^$/d' | perl -MDigest::MD5=md5_hex -ne 'print md5_hex($_),"\n"' | cat -n >/tmp/b.txt
