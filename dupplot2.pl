#!/usr/bin/perl
# Usage ./dupplot.pl file1 file2 ;
# gnuplot, and type: set title "My Plot";  plot '/tmp/data'
# Author Raimon Grau <raimonster@gmail.com>. Artistic License v2.0

use strict;
use warnings;
use Data::Dumper;
use Digest::MD5;
use File::Basename;
use File::Temp;

sub say {print @_,"\n";}

my %sanitizer = (".pl" => sub { $_ = shift; $_;  },
                 ".rb" => sub {
                   $_ = shift;
                   s/^\s*end\s*$//;
                   $_;
                 },
                 ".lisp" => sub {
                   $_ = shift;
                   s/;.*//;
                   s/\)+$/\)/;
                   $_;
                 }
                );

sub extension_for {
  my $fn = shift;
  my ($name, $dir, $ext) = fileparse($fn, qr/\.[^.]*/);
  return $ext;
}

my %h = ();
my @tuples = ();

sub process_file {
  my ($fn, $sub) = (shift, shift);

  open(my $fh, "<", $fn)
    or die "Can't open < input.txt: $!";
  my $ext = extension_for($fn);

  my $md5;
  while(<$fh>){
    chomp;

    $_ = $sanitizer{$ext}->($_) if exists $sanitizer{$ext};

    next if /^\s*$/;
    $md5 = Digest::MD5::md5_hex($_);
    $sub->($md5);
  }
  close $fn;
  return;
}

sub main {
  process_file(shift, sub { push @{$h{$_}}, $.;});
  process_file(shift,
               sub {
                 for (@{$h{$_}}) {
                   push @tuples, [$. , $_];
                 }
               });


  my ($ffo, $name) = mkstemp("/tmp/tempXXXXXXXX");

  for my $tuple (@tuples) {
    #say $tuple->[0], " " , $tuple->[1] ;
    print $ffo $tuple->[0], " " , $tuple->[1] , "\n";
  }
  system(qq|gnuplot -p -e "plot '$name'"|);
}

main(@ARGV);
