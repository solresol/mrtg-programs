#!/usr/bin/perl -w

use strict;

=head1 hrStorage.pl

This program takes a community string, a hostname and a filesystem mount
point and reports back the number of bytes free and the number of bytes
of filesystem size.

It has only been tested with the SNMP walk which comes with HP Network
Node Manager. Which is a bit silly, it should use the MRTG libraries.

=cut

my $comm_string = shift;
my $target = shift;
my $mount_point = shift;

my $snmpwalk = '/opt/OV/bin/snmpwalk';
my $snmpget = '/opt/OV/bin/snmpget';


my $index;

open(SNMPWALK,"$snmpwalk -c '$comm_string' '$target' host.hrStorage.hrStorageTable.hrStorageEntry.hrStorageDescr |")  || die "Couldn't run $snmpwalk";
while(<SNMPWALK>) {
  chomp;
  my ($mib,$vartype,$value) = split(/\s*:\s*/,$_,3);
  my (@mibsplit) = split(/\./,$mib);
  $index = $mibsplit[$#mibsplit];
  $value =~ s/\s*$//;
  if ($value eq $mount_point) { 
    last;
  }
}
close(SNMPWALK);

sub snmpget {
 my $oid = shift;
 open(SNMPGET,"$snmpget -c '$comm_string' '$target' $oid |") || die "Couldn't run $snmpget";
 my $line = <SNMPGET>;
 chomp $line;
 my ($mib,$type,@value) = split (/\s*:\s*/,$line);
 my $value = join(":",@value);
 close(SNMPGET);
 return $value;
}

my $allocation_units = snmpget ("host.hrStorage.hrStorageTable.hrStorageEntry.hrStorageAllocationUnits.$index");
my $used = snmpget ("host.hrStorage.hrStorageTable.hrStorageEntry.hrStorageUsed.$index");
my $size = snmpget ("host.hrStorage.hrStorageTable.hrStorageEntry.hrStorageSize.$index");

my $uptime = snmpget("system.sysUpTime.0");
my $sysname = snmpget("system.sysName.0");

print $allocation_units * ($size-$used)."\n";
print $allocation_units * $size."\n";
print "$uptime\n";
print "$sysname\n";
