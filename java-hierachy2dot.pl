#!/usr/bin/perl
use strict;
use warnings;

my $include = "";
my $exclude = "";
my $filename = "";
my $fh = *STDIN;
my $this_class = "";
my $style = "";
my $comment = 0;
my $i;

foreach $i (0 .. $#ARGV) {
	if ($ARGV[$i - 1] =~ /(-i|--include)/) {
		$include = $ARGV[$i];
	} elsif ($ARGV[$i - 1] =~ /(-e|--exclude)/) {
		$exclude = $ARGV[$i];
	} elsif ($ARGV[$i] !~ /(-i|--include|-e|--exclude)/) {
		$filename = $ARGV[$i];
	}
}

if (length($filename) != 0) {
	close $fh;
	open $fh, "<", $filename or die "$!";
}

print 'strict digraph G {
    rankdir = RL
    fontname = "Bitstream Vera Sans"
    fontsize = 8
    node [ fontname = "Bitstream Vera Sans"
           fontsize = 8
           margin = .3
           shape = "record" ]
    edge [ arrowhead = "empty" ]

';

while (<$fh>) {
	if (m'^\s*//') {
		next;
	} elsif (m'^\s*/\*') {
		$comment = 1;
		next;
	} elsif (m'\*/') {
		$comment = 0;
	}

	if ($comment == 1) {
		next;
	}

	if (/public\s*(static)?\s*class\s+(\w*)\s+(extends|implements)/) {
		if (m'//.*(class)' ||
			m'/\*.*(class)' ||
			m'(class).*;') {
			next;
		}
		$this_class = $2;
		$this_class =~ s/^\s+|\s+$//g;
	}

	if (length($this_class) != 0) {
		while ($_ =~/(extends|implements|^\s+|,)\s+([<>\.\w]+)\s*/g) {
			my $super_class = $2;
			if ($1 =~ /implements/) {
				$style = "[style=dashed]";
			}

			$super_class =~ s/^\s+|\s+$//g;

			if (length($exclude) != 0 &&
				($super_class =~ /($exclude)/ ||
				 $this_class =~ /($exclude)/)) {
				next;
			}
			
			if (length($include) == 0) {
				print "    \"$this_class\" -> \"$super_class\" $style\n";
			} elsif ($super_class =~ /($include)/ ||
					 $this_class =~ /($include)/) {
				print "    \"$this_class\" -> \"$super_class\" $style\n";
			}
		}
	}

	if (length($this_class) != 0 && $_ =~ /{/) {
		$this_class = "";
		$style = "";
	}
}

print "}\n";
close $fh;
