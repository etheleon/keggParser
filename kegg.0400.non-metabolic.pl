#!/usr/bin/env perl

use strict;
use v5.10;

die "$0 <installDIR>" unless $#ARGV == 0;

my $installDIR = $ARGV[0];

my %kohash;

open my $allkos, "<", "$installDIR/misc/ko_nodedetails" || die "$! no such file: $installDIR/misc/ko_nodedetails";
while(my $entry = <$allkos>)
{
    chomp $entry;
    my $ko = (split /\t/, $entry)[0];
    if($ko =~ m/K\d{5}/){
    $kohash{$ko} = $entry."\tko\n";
    }
}

open my $metabkos, "<", "$installDIR/out/nodes/newkonodes" || die "$! no such file: $installDIR/out/nodes/newkonodes";
while(my $entry = <$metabkos>)
{
    unless($. == 1)
    {
        my $ko = (split /\t/, $entry)[0];
        delete $kohash{$ko};
    }
}
close $metabkos;

open my $final, ">>", "$installDIR/out/nodes/newkonodes" || die "$! no such file: $installDIR/out/nodes/newkonodes";
print $final $kohash{$_} foreach (keys %kohash);

#allKOs  = read.table("misc/ko_nodedetails",sep="\t",comment.char="", h=F, fill=T)
#metabKO = read.table("out/nodes/newkonodes")
