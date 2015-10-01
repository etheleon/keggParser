#!/usr/bin/env perl

use strict;
use v5.10;


die "USAGE: $0 KEGGftp/module/module" unless $#ARGV == 0;

$/ = '///';

say join "\t", qw/modID name type ko/;

open(INPUT, $ARGV[0]) || die $!;

while(<INPUT>){
    chomp;
    if(m/^ENTRY\s+M\d{5}/m){
        my ($module, $type)  =  $_ =~ m/^ENTRY\s+  (M\d{5}) \s+ (\S+) \s+Module$/xm;
        my ($name)           =  $_ =~ m/^NAME\s+(\S.*)$/xm;
        my ($kos)            =  $_ =~ m/^DEFINITION\s+(\S.*)$/xm;
        my @allKOS           =  ($kos =~ m/(K\d{5})/xg);
        my %hash;
        $hash{$_}++ for @allKOS;
        $name =~ s/\t//g;

        unless(scalar @allKOS == 0){
            say join "\t", $module,$name,$type,$_ for keys %hash;
        }
    }
}
