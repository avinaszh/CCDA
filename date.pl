#!/usr/bin/perl -w 
use strict;

my $date = "5/23/2009";

$date = date_format("mdY_to_Ymd", $date);

print "$date\n";

sub date_format  {
    # TODO: accept multiple formats
    my $format = shift;
    my $var = shift;
    my @split_date;
    my $date;
    my $ret;

    $var =~ s/\//-/g;

    if ($format eq "mdY_to_Ymd") {
        # From month-day-year date create the SQL date format
        print "$var\n";
        @split_date = split(/-/, $var);
        #$date = "$split_date[2]-$split_date[0]-$split_date[1]";
        $date = $split_date[1];
    }

    if ($format eq "Ymd_to_mdY") {
        # From SQL date create the month-day-year date format
        @split_date = split(/-/, $var);
        $date = "$split_date[1]-$split_date[2]-$split_date[0]";
    }

    $ret = $date;

return $ret;
}

