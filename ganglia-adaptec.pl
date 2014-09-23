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

my $pidfile = "/tmp/ganglia-adaptec.pid";

my $arcconf_bin = "/usr/StorMan/arcconf";
my $arcconf_opts = "GETCONFIG 1";
my $arcconf_cmdline = $arcconf_bin . " " . $arcconf_opts;

&check_single;

open(my $fh, "$arcconf_cmdline|") or die;

my $temperature;
my $drivesOnline = 0;

while(<$fh>) {
 switch () {
   case m/Temperature/ { $temperature = $1 if (/:\ (\d+)/) ;  next; }
   case m/Device is a Hard drive/ {
    if ((<$fh>) =~ /Online/) { $drivesOnline++ ; next; }
   }
 }
}
close($fh);


&send_data("temperature", $temperature);
&send_data("drives_online", $drivesOnline);

&cleanup;

sub send_data() {
 my ($data_type, $value) = @_;

 die if not $value;
 die if not $data_type;
 
 switch ($data_type) {
  case "temperature" { send_temperature($value) }
  case "drives_online" { send_drives_num($value) }
 }
}

sub send_temperature {
 my $val = shift;
 my $cmd = "/usr/bin/gmetric -n \"adaptec.ctl0.temperature\" -v $val -t int8 -u \"Celcius\"";
 system($cmd);
 die if $? != 0;
}
sub send_drives_num {
 my $val = shift;
 my $cmd = "/usr/bin/gmetric -n \"adaptec.ctl0.drives_online\" -v $val -t int8 -u \"Number\"";
 system($cmd);
 die if $? != 0; 
}


sub check_single() {
 if (! -e $pidfile) {
   &save_pid_to_file($pidfile);
   #print "new pid file\n";
 } else {
   my $other_pid = &get_pid_from_file($pidfile);
   if ($other_pid  && -d "/proc/$other_pid") {
      print "ERROR: another copy running : pid $other_pid\n";
      exit 2;
   } else {
      &save_pid_to_file($pidfile);
      #print "owerwrite pid file\n";
   }
 }
}
sub cleanup() {
 my $cmd = "/bin/rm -f $pidfile";
 system($cmd);
}
sub save_pid_to_file() {
 my $f = shift;
 open(my $fh, '>', $f) or die;
 print $fh $$;
 close($f);
}
sub get_pid_from_file() {
 my $f = shift;
 open (my $fh, '<', $f) or die;
 my $pid = <$fh>;
 close($fh);
 return $pid;
}
