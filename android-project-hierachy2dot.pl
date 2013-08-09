#!/usr/bin/perl
use strict;
use warnings;

my $include = "";
my $exclude = "";
my $i;

foreach $i (0 .. $#ARGV) {
	if ($ARGV[$i - 1] =~ /(-i|--include)/) {
		$include = $ARGV[$i];
	} elsif ($ARGV[$i - 1] =~ /(-e|--exclude)/) {
		$exclude = $ARGV[$i];
	}
}

print 'strict digraph G {
    rankdir = LR
    fontname = "Bitstream Vera Sans"
    fontsize = 8
    node [ fontname = "Bitstream Vera Sans"
           fontsize = 8
           margin = .3
           shape = "record" ]
    edge [ arrowhead = "open" ]

';

my @project_files = `find . -iname 'project.properties'`;
foreach $i (0 .. $#project_files) {
	my $file_name = $project_files[$i];
	$file_name =~ s/^\s+|\s+$//g;
	open my $fh, "<", $file_name or die "$!";
	my $this_project = $file_name;
	$this_project =~ s/\.\/|\/project.properties//g;

	while (<$fh>) {
		if (m'android.library.reference.\d=.*/([\w-]*)') {
			my $ref_project = $1;

			if (length($exclude) != 0 &&
				($this_project =~ /($exclude)/ ||
				 $ref_project =~ /($exclude)/)) {
				next;
			}
			if (length($include) == 0) {
				print "    \"$this_project\" -> \"$ref_project\" \n";
			} elsif ($this_project =~ /($include)/ ||
					 $ref_project =~ /($include)/) {
				print "    \"$this_project\" -> \"$ref_project\" \n";
			}
		}
	}

	close $fh;
}

print "}\n";
