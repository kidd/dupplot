#!/usr/bin/perl
# Usage ./dupplot.pl file1 file2 [output_image_file];
# Author Raimon Grau <raimonster@gmail.com>. Artistic License v2.0

# The mechanism to detect similar lines in 2 files is to process both
# files line per line and see if we can consider them equal.

# We should keep in mind that a file might have repeated lines in
# itself, so instead of comparing line numbers which would be
# inefficient, we transform the lines to their md5 and use that as an
# index. That way similar lines will fall into the same bucket by
# design.

# When parsing the first file we create a hash with md5 as keys and a
# list of line numbers as values.

# When parsing the second file we reach out to the previous hash and
# create tuples of [line_in_previous_file, current_line] foreach
# line_in_previous_file with the same md5 as current_line.

# After that, we just launch gnuplot. If there's a 3rd argument, store
# the resulting graph as a png file.

use strict;
use warnings;
use Data::Dumper;
use Digest::MD5;
use File::Basename;
use File::Temp;

sub say {print @_,"\n";}

# This hash represents the mapping between the file formats and the
# normalization operations that we can do safely in each one of them.
my %sanitizer = (".pl" => sub {
                   $_ = shift;
                   s/^\s*[{}]\s*$//; # remove lines with single { or }
                   s/^\s*[}]\s*else\s*[{]\s*$//; # remove }?else{? lines
                   $_;
                 },
                 ".rb" => sub {
                   $_ = shift;
                   s/^\s*end\s*$//; # remove lines with 'end'
                   $_;
                 },
                 ".lisp" => sub {
                   $_ = shift;
                   s/;.*//; # comments
                   s/\)+$/\)/; # collapse multiple closing parens to one
                   $_;
                 }
                );

sub extension_for {
  my $fn = shift;
  my ($name, $dir, $ext) = fileparse($fn, qr/\.[^.]*/);
  return $ext;
}

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
    $sub->($md5, $.); # pass the md5 of the current line and the line
                      # number ($.)
  }
  close $fn;
  return;
}

sub output_file {
  my $output_file = shift;
  my $file_cmd = "";
  if ($output_file) {
    $file_cmd = "set terminal png size 400,300; set output '$output_file.png';"
  }
  $file_cmd;
}

sub main {

  # %h is the hash that accumulates the lines of the first file its keys
  # are an md5 of the line, and the values are lists of line numbers
  # where that line appears.
  my %h = ();

  # The array @tuples stores all the points that have to be written in
  # the final plot
  my @tuples = ();

  process_file(shift, sub {
                 # Adds the line number to the value of %h indexed by
                 # the md5 of the line itself
                 my ($line, $lnum) =  @_;
                 push @{$h{$line}}, $lnum;
               });
  process_file(shift,
               sub {
                 # For every line, if it exists in the previous file,
                 # make a correspondence with each appearance
                 # (cartesian product)
                 my ($line, $lnum) =  @_;
                 for my $other_file_line (@{$h{$line}}) {
                   push @tuples, [$lnum , $other_file_line];
                 }
               });

  my ($f_handler, $name) = mkstemp("/tmp/tempXXXXXXXX");

  for my $tuple (@tuples) {
    #say $tuple->[0], " " , $tuple->[1] ;
    print $f_handler $tuple->[0], " " , $tuple->[1] , "\n";
  }

  my $file_cmd = output_file(shift);
  system(qq|gnuplot -p -e "$file_cmd plot '$name'"|);

}

main(@ARGV);
