#!/usr/bin/perl -w

=head1 NAME

C<hpux-cfgmaker.pl> - create MRTG configuration for HP-UX system

=head1 SYNOPSIS

C<hpux-cfgmaker.pl> [I<file...>] I<host>

=head1 DESCRIPTION

C<hpux-cfgmaker.pl> will probe an HP-UX server via SNMP to find out
its network interfaces and disks, and create an MRTG configuration
file from that information. This gets printed out on STDOUT. Redirect
this to a file, and then schedule C<mrtg> I<filename> every five minutes
in cron.

If you want to, you can also include custom snippets by mentioning the
filename on the command-line.

Make sure that C<SNMP_HPUNIX_START=1> in C</etc/rc.config.d/SnmpHpunix>
or else no disks will be discovered.

=head1 BUGS

At the moment, this can't cope with a community string other than I<public>.

=cut

use strict;

use lib '/usr/local/lib/mrtg2';
use SNMP_util;

use constant HPUX_TOTAL_SIZE      => '.1.3.6.1.4.1.11.2.3.1.2.2.1.4';
use constant HPUX_FREE_DISK_SPACE => '.1.3.6.1.4.1.11.2.3.1.2.2.1.5';
use constant HPUX_BLOCK_SIZE      => '.1.3.6.1.4.1.11.2.3.1.2.2.1.7';
use constant HPUX_DISK_DEVICE     => '.1.3.6.1.4.1.11.2.3.1.2.2.1.9';
use constant HPUX_MOUNT_POINT_MIB => '.1.3.6.1.4.1.11.2.3.1.2.2.1.10';

my $command_line = join(" ",$0,@ARGV);
my $today = localtime;
die "Missing target host" if ($#ARGV == -1);
my $target_host = pop;  # it's the *last* argument


######################################################################
# Global variables. These really should be arguments to this program,
# but anyway...

print qq{
# This file created with:
#   $command_line
# on 
#   $today
#
HtmlDir: /aon/mrtg/html
ImageDir: /aon/mrtg/html/images
LogDir: /aon/mrtg/logs
EnableIPv6: no
ThreshMailServer: localhost
ThreshMailSender: mrtg\@auhpmg01.apac.aon.bz
ThreshMailAddress[_]: root\@auhpmg01.apac.aon.bz



};

######################################################################
# Get all the files mentioned on the command-line before including other
# stuff.

if ($#ARGV != -1) {
  print while (<>);
  print "\n\n\n";
}

######################################################################
# The standard, fixed MIB variables.
print qq!
Target[${target_host}_users]: .1.3.6.1.4.1.11.2.3.1.1.2.0&.1.3.6.1.4.1.11.2.3.1.1.2.0:public\@${target_host}
MaxBytes[${target_host}_users]: 1000
Title[${target_host}_users]: Logged-in users on ${target_host}
PageTop[${target_host}_users]: <h1>Logged-in users on ${target_host}</h1>
Options[${target_host}_users]: gauge,nolegend,growright,noi
YLegend[${target_host}_users]: Users
Legend1[${target_host}_users]: Average number of logged-in users
Legend2[${target_host}_users]: Average number of logged-in users
Legend3[${target_host}_users]: Peak logged-in users
Legend4[${target_host}_users]: Peak logged-in users
ShortLegend[${target_host}_users]: Users
LegendI[${target_host}_users]: Users:
LegendO[${target_host}_users]: Users:
WithPeak[${target_host}_users]: ymw

Target[${target_host}_avg1min]: .1.3.6.1.4.1.11.2.3.1.1.3.0&.1.3.6.1.4.1.11.2.3.1.1.3.0:public\@${target_host}
MaxBytes[${target_host}_avg1min]: 100
AbsMax[${target_host}_avg1min]: 10000
Title[${target_host}_avg1min]: 1 minute load average for ${target_host}
PageTop[${target_host}_avg1min]: <h1>1 minute load average for ${target_host}</h1>
Options[${target_host}_avg1min]: gauge,nolegend,growright
YLegend[${target_host}_avg1min]: % cpu occupied
Legend1[${target_host}_avg1min]: % cpu occupied
Legend2[${target_host}_avg1min]: % cpu occupied
ShortLegend[${target_host}_avg1min]: \%cpu
LegendI[${target_host}_avg1min]: % cpu occupied
LegendO[${target_host}_avg1min]: % cpu occupied

Target[${target_host}_avg5min]: .1.3.6.1.4.1.11.2.3.1.1.4.0&.1.3.6.1.4.1.11.2.3.1.1.4.0:public\@${target_host}
MaxBytes[${target_host}_avg5min]: 100
AbsMax[${target_host}_avg5min]: 10000
Title[${target_host}_avg5min]: 5 minute load average for ${target_host}
PageTop[${target_host}_avg5min]: <h1>5 minute load average for ${target_host}</h1>
Options[${target_host}_avg5min]: gauge,nolegend,growright
YLegend[${target_host}_avg5min]: % cpu occupied
Legend1[${target_host}_avg5min]: % cpu occupied
Legend2[${target_host}_avg5min]: % cpu occupied
ShortLegend[${target_host}_avg5min]: \%cpu
LegendI[${target_host}_avg5min]: % cpu occupied
LegendO[${target_host}_avg5min]: % cpu occupied

Target[${target_host}_avg15min]: .1.3.6.1.4.1.11.2.3.1.1.5.0&.1.3.6.1.4.1.11.2.3.1.1.5.0:public\@${target_host}
MaxBytes[${target_host}_avg15min]: 100
AbsMax[${target_host}_avg15min]: 10000
Title[${target_host}_avg15min]: 15 minute load average for ${target_host}
PageTop[${target_host}_avg15min]: <h1>15 minute load average for ${target_host}</h1>
Options[${target_host}_avg15min]: gauge,nolegend,growright
YLegend[${target_host}_avg15min]: % cpu occupied
Legend1[${target_host}_avg15min]: % cpu occupied
Legend2[${target_host}_avg15min]: \%cpu
ShortLegend[${target_host}_avg15min]: % cpu occupied
LegendI[${target_host}_avg15min]: % cpu occupied
LegendO[${target_host}_avg15min]: % cpu occupied


Target[${target_host}_mem_and_swap]: .1.3.6.1.4.1.11.2.3.1.1.7.0&.1.3.6.1.4.1.11.2.3.1.1.12.0:public\@${target_host} * 1024
MaxBytes[${target_host}_mem_and_swap]: 16000000
Title[${target_host}_mem_and_swap]: Free memory and free swap space for ${target_host}
PageTop[${target_host}_mem_and_swap]: <h1>Free memory and free swap space for ${target_host}</h1>
Options[${target_host}_mem_and_swap]: gauge,nolegend,growright,nopercent
YLegend[${target_host}_mem_and_swap]: Bytes free
Legend1[${target_host}_mem_and_swap]: Free real memory
Legend2[${target_host}_mem_and_swap]: Free swap space
ShortLegend[${target_host}_mem_and_swap]: bytes
LegendI[${target_host}_mem_and_swap]: Free real memory:
LegendO[${target_host}_mem_and_swap]: Free swap space:
Kilo[${target_host}_mem_and_swap]: 1024

Target[${target_host}_user_cpu]: .1.3.6.1.4.1.11.2.3.1.1.13.0&.1.3.6.1.4.1.11.2.3.1.1.16.0:public\@${target_host}
MaxBytes[${target_host}_user_cpu]: 100
Title[${target_host}_user_cpu]: User and nice CPU usage for ${target_host}
PageTop[${target_host}_user_cpu]: <h1>User and nice CPU usage for ${target_host}</h1>
Options[${target_host}_user_cpu]: nolegend,growright
YLegend[${target_host}_user_cpu]: CPU usage
Legend1[${target_host}_user_cpu]: User processes
Legend2[${target_host}_user_cpu]: Niced processes
ShortLegend[${target_host}_user_cpu]: pct 
LegendI[${target_host}_user_cpu]: User processes:
LegendO[${target_host}_user_cpu]: Niced processes:
WithPeak[${target_host}_user_cpu]: ymw

Target[${target_host}_system_cpu]: .1.3.6.1.4.1.11.2.3.1.1.14.0&.1.3.6.1.4.1.11.2.3.1.1.14.0:public\@${target_host}
MaxBytes[${target_host}_system_cpu]: 100
Title[${target_host}_system_cpu]: System CPU usage for ${target_host}
PageTop[${target_host}_system_cpu]: <h1>System CPU usage for ${target_host}</h1>
Options[${target_host}_system_cpu]: nolegend,growright
YLegend[${target_host}_system_cpu]: kernel cpu
Legend1[${target_host}_system_cpu]: Percentage of system CPU usage
Legend2[${target_host}_system_cpu]: Percentage of system CPU usage
ShortLegend[${target_host}_system_cpu]: pct
LegendI[${target_host}_system_cpu]: Percentage of system CPU usage:
LegendO[${target_host}_system_cpu]: Percentage of system CPU usage:
WithPeak[${target_host}_system_cpu]: ymw
!;

######################################################################
# Identify filesystems

my ($key,$value,$line);
my %mountpoints;
my %blocksize;
foreach $line (snmpwalk($target_host,HPUX_MOUNT_POINT_MIB)) {
  ($key,$value) = split(/:/,$line,2);
  $mountpoints{$key} = $value;
}
foreach $line (snmpwalk($target_host,HPUX_BLOCK_SIZE)) {
  ($key,$value) = split(/:/,$line,2);
  $blocksize{$key} = $value;
}




my ($id,$mpt);
while (($id,$mpt) = each %mountpoints) {
  my $bsize;
  my $slashless = $mpt;
  $slashless =~ s:/:_:g;
  if ($slashless eq "_") { $slashless = '_root'; }
  $bsize = 1000 * $blocksize{$id}/1024;
 print qq!
Target[${target_host}_diskspace${slashless}]: .1.3.6.1.4.1.11.2.3.1.2.2.1.5.$id&.1.3.6.1.4.1.11.2.3.1.2.2.1.4.$id:public\@${target_host} * $bsize
MaxBytes[${target_host}_diskspace${slashless}]: 100000000000
Title[${target_host}_diskspace${slashless}]: ${target_host} $mpt
PageTop[${target_host}_diskspace${slashless}]: <h1>${target_host}:$mpt free space</h1>
Options[${target_host}_diskspace${slashless}]: nolegend,growright,gauge,dorelpercent,nopercent,noo,pngdate
kilo[${target_host}_diskspace${slashless}]: 1024
YLegend[${target_host}_diskspace${slashless}]: Free disk space
Legend1[${target_host}_diskspace${slashless}]: Free disk space
Legend2[${target_host}_diskspace${slashless}]: Total size
ShortLegend[${target_host}_diskspace${slashless}]: bytes
LegendI[${target_host}_diskspace${slashless}]: Free disk space
LegendO[${target_host}_diskspace${slashless}]: Total size
ThreshMinI[${target_host}_diskspace${slashless}]: 50
!
;
}

######################################################################
# MRTG can already figure out what interfaces there are there.

open(INTERFACE_STUFF,"cfgmaker $target_host|") || die "Can't run cfgmaker";
while (<INTERFACE_STUFF>) {
  next if /^#/;
  next if /^\s*$/;
  next if /EnableIPv6/;
  print;
  if (/^Target\[(.*)\]:/) {
    print "Options[$1]: growright,bits\n";
  }
}
