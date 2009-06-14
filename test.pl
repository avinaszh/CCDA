#!/usr/bin/perl -w
use strict;

my @arr;

@arr = ('id','name','alias');

rout('1',\@arr);

sub rout {
    my ($x,$in) = @_;

    foreach (@$in) {
        print "$_\n";
    }

}
