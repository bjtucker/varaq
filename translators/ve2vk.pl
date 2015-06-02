#!/usr/bin/perl

# ve2vk.pl
# var'aq interpreter translator
# created: 09 Sep 2000 by j proctor

# This is a quick-and-dirty program to translate var'aq keywords in its
# interpreter program.  I make no apologies for failing to use strict 
# (or any other little nicety that would suggest I actually intended to
# show this code to anyone, use it in a real-world situation, or ever 
# have to maintain it).  -- j

# Needs file varaq.dict in current working directory.  Assumes stdin is 
# varaq-en.pl; outputs varaq-kl.pl to stdout.  If something's not in 
# the dictionary, it doesn't get translated.

# Future enhancements: allow command-line specification/override of 
# varaq.dict name/location, source file name/location, source file 
# language, output file name/location, output file language, multiple
# output files for different languages, and some way to automagically
# fix the comments that say things like "This is the English version."

open(DICT, "varaq.dict") || die;

while (<DICT>)
	{
	next if (m/^\s*$/);
	next if (m/^\s*#/);

# Ideally, what I'd be doing here is grabbing the first line and using 
# it to set up my data structure.  Oh well.  I've at least designed the
# struct so it's easy to add other languages, although it'll be a bit
# nastier if we break the "source is English" assumption.

	chomp;
	@row = split "\t";
	
	if ($row[1] =~ /\|/)
		{
		@variants = split('|', $row[1]);
		$row[1] = $variants[0];
		}
	$cmd{$row[0]}{'tlh'} = $row[1];
	}

close(DICT);

# Now, on to the actual translation:

while (<>)
	{
	if (m/\(\$cmd eq '(.+?)'\)/)
		{
		s/'($1)'/q($1)/;
		}
	if (m/\(\$cmd eq q\((.+?)\)\)/)
		{
		if (defined($cmd{$1}{'tlh'}))
			{
			s/\(($1)\)/($cmd{$1}{'tlh'})/;
			}
		}
	print;
	}
