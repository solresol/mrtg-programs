#!/usr/bin/perl -w
use bignum;

=head1 NAME

proc-usage.pl

=head1 SYNOPSIS

proc-usage.pl C<[-others]> C<[hostname]> I<outputdir> I<appname:selection_rule appname2:selection_rule ...>

=head1 DESCRIPTION

C<proc-usage.pl> is a program for collecting statistics about applications
so that they can be graphed with mrtg.

=head1 OPTIONS

=over

=item -others

Print out the list of processes which ended up in the OTHERS group

=item I<hostname>

If present, instead of getting a local process list, it runs ssh to
the hostname given and runs ps there. 

=item I<outputdir>

The directory where output files are going to be put.

=item I<appname:selection_rule>

Repeated as many times as needed, for each application. The file
I<appname>C<.mrtg> (in the I<outputdir>) directory will be created.

=back

=head1 SELECTION RULES

The selection rules determine whether a process should be counted
towards a particular I<appname>.

A selection can be in any of the following formats:

=over

=item comm=I<something>

The command the process was invoked as, or its current argv matches
one of the comma-separated regexps in I<something>. C<comm=> can be omitted.

=item user=I<something>

The user the process is running as matches one of the comma-separated regexps in  I<something>

=item group=I<something>

The group the process is running as matches one of the comma-separated regexps in I<something>.

=back

=head1 EXAMPLES

C<proc-usage.pl /tmp samba:smbd,nmbd web:group=www system:user=root>

This will create 4 files:

=over

=item /tmp/samba.mrtg

=item /tmp/web.mrtg

=item /tmp/system.mrtg

=item /tmp/OTHER.mrtg

=back

If you create an MRTG config file with the following command:

C<app-cfgmaker.sh `hostname` samba web system>

Then MRTG will create 8 graphs, cpu and memory for each of the 4 applications.


=head1 AUTHOR

Greg Baker (gregb@ifost.org.au)

=cut

#
# Each selection rule is either
# or
#  comm=something
#
# There's a default appname of "OTHER" which matches everything not
# otherwise covered.
#   
use strict;

die "Must give an output directory" unless @ARGV;
my $show_others = 0;
if ($ARGV[0] eq '-others') { $show_others = 1; shift @ARGV; }

my $output_dir;
my $target_host = shift @ARGV;
if ($target_host =~ m:/:) { 
 $output_dir = $target_host;
 $target_host = "";
} else {
 $output_dir = shift @ARGV;
 die "Don't try anything foolish" if $output_dir =~ m:\.\.:;
}

my $command = ($target_host eq "" ? "" : "ssh $target_host ").
                "UNIX95=1 ps -o ppid,pcpu,vsz,user,group,comm,args -A" ;

my $arg;
my %cpu_buckets = ( OTHER => 0.0 );
my %memory_buckets = ( OTHER => 0 );
my $line;
my $total_cpu = 0.0;
my $total_memory = 0;
open(PS,"$command|") || die "Couldn't run $command";
my $first_line = 1;
LINE:
while ($line = <PS>) {
 chomp $line;
 if ($first_line) { $first_line = 0; next LINE; }
 $line =~ s/^ *//;
 $line =~ s/ *$//;
 my ($ppid,$pcpu,$vsz,$user,$group,$comm) = split(/\s+/,$line);
   # $comm actually gets comm,args
 $vsz *= 1024;
 next LINE if $ppid == 0; # ignore kernel threads
 $total_cpu += $pcpu;
 $total_memory += $vsz;
 foreach $arg (@ARGV) {
   my ($appname,$selection_rule) = split(/:/,$arg,2);
   if ($selection_rule !~ /=/) { $selection_rule = "comm=".$selection_rule; }
   my ($selector,$required_values) = split(/=/,$selection_rule,2);
   $cpu_buckets{$appname} = 0.0 unless exists $cpu_buckets{$appname};
   $memory_buckets{$appname} = 0.0 unless exists $memory_buckets{$appname};
   my $thing_to_match = $selector =~ /user/i ? $user :
			$selector =~ /group/i ? $group : $comm;
   my $possible_value;
   foreach $possible_value (split(/,/,$required_values)) {
     if ($thing_to_match =~ /$possible_value/) {
       $cpu_buckets{$appname} += $pcpu;
       $memory_buckets{$appname} += $vsz;
       next LINE;
     }	
   }
 }
 $cpu_buckets{OTHER} += $pcpu;
 $memory_buckets{OTHER} += $vsz;
 print STDERR "OTHER included process user=$user group=$group comm=$comm\n" 
   if $show_others;
}
close(PS);

my $uptime;
my $hostname;
if ($target_host eq "") { 
  $uptime = `uptime`;
  $hostname = `hostname`;
  chomp($uptime);
  chomp($hostname);
} else {
  $uptime = "";
  $hostname = $target_host;
}
my $app;
foreach $app (keys %cpu_buckets) {
  open(OUT,">$output_dir/${app}-cpu.mrtg") || die "Couldn't write to $output_dir/$app.mrtg";
  print OUT "$cpu_buckets{$app}\n$total_cpu\n$uptime\n$hostname\n";
  die "The impossible happened for app=$app" if $cpu_buckets{$app} > $total_cpu;
  close(OUT);
  open(OUT,">$output_dir/${app}-mem.mrtg") || die "Couldn't write to $output_dir/$app.mrtg";
  print OUT "$memory_buckets{$app}\n$total_memory\n$uptime\n$hostname\n";
  die "The impossible happened for app=$app" if $memory_buckets{$app} > $total_memory;
  close(OUT);
}
