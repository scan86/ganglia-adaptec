#!/usr/bin/perl 
#===============================================================================
#
#         FILE:  test.pl
#
#        USAGE:  ./test.pl  
#
#  DESCRIPTION:  
#
#      OPTIONS:  ---
# REQUIREMENTS:  ---
#         BUGS:  ---
#        NOTES:  ---
#       AUTHOR:  Dmitriy Anikin (scan), danikin@creditnet.ru
#      COMPANY:  NKB
#      VERSION:  1.0
#      CREATED:  09/17/2014 03:58:04 PM
#     REVISION:  ---
#===============================================================================

use strict;
use warnings;
use diagnostics;
use Switch;

open(my $fh, '<',  "arcconf");

my $t;
my $online_disks = 0;

my $temperature;
my $onlineDrives = 0;

while(<$fh>) {
 switch () {
   case m/Temperature/ { $temperature = $1 if (/:\ (\d+)/) }
   case m/Device is a Hard drive/ { checkDrive($_)  }   
 }

}

sub checkDrive {
 if ((my $line = <$fh>) =~ /Online/) { $onlineDrives++ }
}

print $temperature, "\n";
print $onlineDrives, "\n";


close($fh);