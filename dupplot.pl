#!/usr/bin/perl
sub say {print @_,"\n";}

open(my $fh, "<", shift)
  or die "Can't open < input.txt: $!";

my %h=();

while(chomp($_= <$fh> )){
  my ($line, $md5) = split;
  $h{$md5} = [] unless defined $h{$md5};
  push @{$h{$md5}}, $line;
}

open(my $fh2, "<", shift)
  or die "Can't open < file: $!";

while(chomp($_= <$fh2> )){
  my ($line, $md5) = split;
  if ($h{$md5}) {
    say $_ ", " , $line for (@$h{$md5});
    #say "|", $h{$md5}, "|" , $line ,"|";
  }
}

# sed -e 's/;.*//' -e 's/ \+/ /' -e'/^$/d' | perl -MDigest::MD5=md5_hex -ne 'print md5_hex($_),"\n"' | cat -n >/tmp/b.txt
