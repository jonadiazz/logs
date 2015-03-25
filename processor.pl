#!/usr/bin/perl
use Modern::Perl;
use Data::Dumper;
use Net::hostent;

my @content; my $CONTENT;
foreach my $cont (@ARGV) {
  open($CONTENT, '<', $cont) or die "Not a file";
  while ( <$CONTENT> ) { chomp;
    push @content, $_;
  }
}
close $CONTENT;
#print Dumper($cont);

my %IPs;
my %count;
my $no_entries;

my %date; my %hour; my %status; my %urlls; my %type_f;
my %browser_id; my %browser; my %referrer; my %ref_domain; my %oS;
for (@content) {
  #regex to find referrer & browser ID
  my ($re, $brs) = ($_ =~ m/".+?".+?"(.+?)".+?"(.+?)"/);
  ($re) = 'NO REFERRER' if $re eq '-';
  $referrer{$re}++;
  $browser_id{$brs}++;
  $count{$re}++;
  $count{$brs}++;
  #to find domain of referrer
  my $rdns = reverse $re;
  $rdns = 'ENON' if $re eq 'NO REFERRER';
  ($rdns) = ($rdns =~ m/(\w+.\w+)/);
  $rdns = reverse $rdns;
  $ref_domain{$rdns}++;
  $count{$rdns}++;
  #regex to find browser name
  my ($s_engine) = ($brs =~ m/(Chrome|Firefox|MSIE|Opera|Safari)/);
  ($s_engine) = 'Unknown' if !$s_engine;
  $browser{$s_engine}++;
  $count{$s_engine}++;
  #regex for Operating System
  my ($osx) = ($brs =~ m/(Linux|Macintosh|Windows)/);
  ($osx) = 'Other' if !$osx;
  $oS{$osx}++;
  $count{$osx}++;
  #regex for url
  ($_ =~ m/\"(?:GET|POST)\s(.*?)\s\w/);
  $urlls{$1}++;
  $count{$1}++;
  #regexes to find type of file based on URL
  if($_ =~ m/jpg|jpeg|gif|ico|png/) {
    $type_f{'Image'}++;
    $count{'Image'}++;
  }
  elsif($_ =~ m/.cgi/) { $type_f{'CGI Program'}++;
  $count{'CGI Program'}++;  }
  elsif($_ =~ m/.css/) { $type_f{'Style Sheet'}++;
  $count{'Style Sheet'}++;  }
  elsif($_ =~ m/.htm|.html/) { $type_f{'Web Pages'}++;
  $count{'Web Pages'}++;  }
  else { $type_f{'Other Request'}++;
  $count{'Other Request'}++;  }

  #regex for status code
  ($_ =~ m/\".+?\"\s(\d+)/);
  $status{$1}++;
  $count{$1}++;
  #regex for date and hour
  ($_ =~ m/\[(.+?)\:(\d+)/);
  $date{$1}++;
  $count{$1}++;
  $hour{$2}++;
  $count{$2}++;
  $no_entries++;
}

#sorting of hash keys into an array (alphabetically)
my @OS =sort {$a cmp $b} keys %oS;
my @rd =sort {$a cmp $b} keys %ref_domain;
my @r = sort {$a cmp $b} keys %referrer;
my @br =sort {$a cmp $b} keys %browser;
my @bID=sort {$a cmp $b} keys %browser_id;
my @ft =sort {$a cmp $b} keys %type_f;
my @url=sort {$a cmp $b} keys %urlls;
my @s = sort {$a cmp $b} keys %status;
my @d = sort {$a cmp $b} keys %date;
my @h = sort {$a cmp $b} keys %hour;

#to find IPs
my $ip = '(\d+.\d+.\d+.\d+)';
for my $line (@content) {
    ($line =~ m/($ip)(.+)/);
    if(exists $IPs{ $2 }) {
      $count{$1}++;
    } else {
      $count{$1}++;
      push @{$IPs { $2 } }, $3;
    }
}

my @c;
#to find hosts readable name
my %resource;
foreach (keys %IPs) {
  $resource{&reverseIP($_)} = $_;
}

my %domains; #will save the domains from the readable address
@c = sort {$a cmp $b} keys %resource;
#print Dumper(@c);
$domains{'DOTTED QUAD OR OTHER'} = 'DOTTED QUAD OR OTHER';
foreach (@c) {
  my $real = $resource{$_};
  #to find domain
  my $dns = reverse $_;
  ($dns) = ($dns =~ m/(\w+.\w+)/);
  $dns = reverse $dns;
  if($real =~ m/$dns/) {
    $count{'DOTTED QUAD OR OTHER'} += $count{$real};
  } else {
    $domains{$dns} = $_;
    $count{$dns} += $count{$real};
  }
}
my @dom = sort {$a cmp $b} keys %domains;

#open() to write results to a text file
open(DOC, '>>', 'jvasquez.summary');
my $doc;
$doc.=&toString("HOSTNAMES", @c);
$doc.=&toString("DOMAINS", @dom);
$doc.=&toString("DATES", @d);
$doc.=&toString("HOURS", @h);
$doc.=&toString('STATUS CODES', @s);
$doc.=&toString('URLS', @url);
$doc.=&toString('FILE TYPES', @ft);
$doc.=&toString('BROWSERS', @bID);
$doc.= &toString('BROWSER FAMILIES', @br);
$doc.= &toString('REFERRERS', @r);
$doc.= &toString('REFERRERS’ DOMAINS', @rd);
$doc.= &toString('OPERATING SYSTEMS', @OS);
print DOC $doc;
print "\n ".'DONE!'."\n\n";
close $doc;

#reverses a dotted IP address to readable format
sub reverseIP() {
  my $name = $_;
  if ( my $h = gethost($_) ) {
    $name = $h->name();
  }
  return $name;
}

#will print formatted data to file/screen/string
sub toString() {
  my $file;
  my $subtitle = shift;
  my @lines = @_;
  $file .= sprintf "="x50;
  $file .= sprintf "\n%s\n%s", $subtitle, "="x50;
  $file .= sprintf "\n\n%9s %8s\t%-30s\n", 'Hits', '%-age', 'Resource';
  $file .= sprintf     "%9s %8s\t%-30s\n", '----', '-----', '--------';

  #print Dumper(@lines);
  foreach my $line (@lines) {
    my $l2 = $line;
    if ($l2 eq '-') {
      $line = 'NO BROWSER ID';
    }
    if($subtitle =~ 'HOSTNAMES') {
      $l2 = $resource{$line};
    }
    my $per = 100*($count{$l2}/$no_entries);
    $file .= sprintf "%9s %8.2f\t%-35s\n", $count{$l2}, $per, $line;
  }
  $file .= sprintf "%9s\n%8s entries displayed\n\n\n", '----', $no_entries;
  return $file;
}
