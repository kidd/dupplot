#!/usr/bin/perl
use strict;
use warnings;
use Data::Dumper;
use Digest::MD5;

sub say {print @_,"\n";}

sub sanitize {
  $_ = shift;
  s/;.*//;
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
    # say "$_";
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
my %h1 = process_file_1(shift);
my $t = process_file_2(shift, \%h1);

# open(my $fh3, "+>/tmp/foo.plot", )
#   or die "Can't open < file: $!";
for my $tuple (@$t) {
  say $tuple->[0], " " , $tuple->[1] ;
}

#close $fh3;

Dumper($t);
#Dumper(\%h1);

# open(my $fh2, "<", shift)
#   or die "Can't open < file: $!";
# say Dumper(\%h1);
# open(my $fh2, "<", shift)
#   or die "Can't open < file: $!";

# while (chomp($_= <$fh2> )) {
#   my ($line, $md5) = split;
#   if ($h{$md5}) {
#     say $_ ", " , $line for (@$h{$md5});
#     #say "|", $h{$md5}, "|" , $line ,"|";
#   }
# }

# sed -e 's/;.*//' -e 's/ \+/ /' -e'/^$/d' | perl -MDigest::MD5=md5_hex -ne 'print md5_hex($_),"\n"' | cat -n >/tmp/b.txt
