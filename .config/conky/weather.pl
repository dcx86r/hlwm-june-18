#!/usr/bin/perl

# 15m interval
# ${execi 900 /path/to/script/weather.pl}

use Encode;
use LWP::Simple;
use XML::LibXML;
use XML::LibXML::XPathContext;

# local weather feed from Weather Canada
my $feed = "https://weather.gc.ca/rss/city/on-85_e.xml";

# get feed
my $page = get($feed);

$page =~ m/<?xml/ or print "Doc empty or invalid" and exit;

my $dom = eval {
	XML::LibXML->load_xml(string => (\$page));
};
if($@) {
	print "Error parsing XML" and exit;
}

# register Atom namespace
my $xpc = XML::LibXML::XPathContext->new($dom);
$xpc->registerNs('Atom', 'http://www.w3.org/2005/Atom');

# find and print just the node with current conditions
my @current = $xpc->findnodes('//Atom:entry/Atom:title');
my $str =  $current[1]->to_literal();
$str =~ s/Current Conditions/Toronto/;
print encode_utf8($str);
exit;
