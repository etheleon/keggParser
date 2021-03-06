#!/usr/bin/env perl

use strict;
use v5.10;

#parses the KO file to generate KO nodes
die "USAGE: $0 KEGGftp/genes/ko/ko" unless $#ARGV == 0;

$/ = '///';	#separator

open(INPUT, $ARGV[0]) || die $!;
while(<INPUT>) {
    my ($KO) = $_ =~ m/ENTRY\s+(K\d+)/xsm;
#Used together, as `m//ms`, they let the "." match any character whatsoever, while still allowing "^" and "$" to match, respectively, just after and just before newlines within the string.
    my ($NAME) = $_ =~ m/NAME\s+(.*?)\n/xsm;
# If you want it to match the minimum number of times possible, follow the quantifier with a "?". Note that the meanings don't change, just the "greediness":
    my ($DEF) = $_ =~ m/DEFINITION\s+(.*?)\n/xsm;
    say "ko:$KO\t$NAME\t$DEF";
}

__END__
the output will be ko_nodedetails
