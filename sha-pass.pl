#!/usr/bin/perl -w

use Digest::SHA1 qw(sha1 sha1_hex);
my $digest = sha1_hex("mypass");

print "$digest\n";
