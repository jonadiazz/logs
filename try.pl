#!/usr/bin/perl
use Modern::Perl;
use Data::Dumper;
use Net::hostent;

my @array = ('ip174-74-97-58.om.om.cox.net',
'ip24-252-5-28.om.om.cox.net',
'ip24-252-61-232.om.om.cox.net',
'ip24-252-8-93.om.om.cox.net',
'ip68-106-208-23.om.om.cox.net',
'ip68-13-115-5.om.om.cox.net',
'ip68-13-119-16.om.om.cox.net',
'baiduspider-123-125-71-53.crawl.baidu.com',
'h34.163.23.98.static.ip.windstream.net',
'107.77.72.26',
);

my $dns;
foreach (@array) {
  #print "\n\n".reverse $_;
  $_ = reverse $_;
  ($dns) = ($_ =~ m/(\w+.\w+)/);
  $dns = reverse $dns;
  printf "  ".$dns." \n";
}
