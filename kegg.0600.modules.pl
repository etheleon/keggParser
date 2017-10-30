#!/usr/bin/env perl

use strict;
use v5.10;


die "USAGE: $0 KEGGftp/module/module outputNode outputEdges" unless $#ARGV == 2;

$/ = '///';


open(INPUT, $ARGV[0]) || die $!;

open(NODE, ">", $ARGV[1]) || die $!;
    say NODE join "\t", qw/module:ID name type l:label/;
open(REL, ">", $ARGV[2]) || die $!;
    say REL join "\t", qw/module:START_ID ko:END_ID relationship:TYPE/;

while(<INPUT>){
    chomp;
    if(m/^ENTRY\s+M\d{5}/m){
        my ($module, $type)  =  $_ =~ m/^ENTRY\s+  (M\d{5}) \s+ (\S+) \s+Module$/xm;
        my ($name)           =  $_ =~ m/^NAME\s+(\S.*)$/xm;
        my ($kos)            =  $_ =~ m/^DEFINITION\s+(\S.*)$/xm;
        my @allKOS           =  ($kos =~ m/(K\d{5})/xg);
        my %kohash;
        $kohash{$_}++ for map { "ko:$_" } @allKOS;
        $name =~ s/\t//g;
        #$type =~ s/([\+\-\&\|\|\!\(\)\{\}\[\]\^\"\~\*\?\:\\])/\\$1/g;
        #$name =~ s/([\+\-\&\|\|\!\(\)\{\}\[\]\^\"\~\*\?\:\\])/\\$1/g;

        unless(scalar @allKOS == 0){    #some modules do not have KOs
            say NODE join "\t", $module,$name,$type,"module";
            say REL join  "\t", $module,$_,"mod2ko" for keys %kohash
        }
    }
}
