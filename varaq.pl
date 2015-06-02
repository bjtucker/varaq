#!/usr/bin/perl

# varaq.pl
#
# the Perl reference implementation of var'aq, the "Klingon Forth".
#
# Last updated 9/19/2000.
# (Jul 14 2000: Chris Pressey generally hacks source to bits and
#  sends back to Brian Connors...)
# (19 sep 2000: j proctor adds some stuff...)
# (2 September 2001 -- Jeff Evarts' list code added...)
#
# (c)2000-2001 Brian Connors (idea, semantics) and Chris Pressey (parsing logic
# and general plumbing) under terms of the Mozilla Public License (see
# <a href="http://www.mozilla.org" target=_blank>http://www.mozilla.org</a> for details).

# A note on comments: I don't distinguish my code from the other guy's code,
# so you'll just have to guess which is which. (Or for that matter who wrote
# which comment.)

### GLOBAL VARIABLES ###

$line  = '';  # last line of text read from the input file
$token = '';  # last token parsed out of $line of text
$proc  = {};  # dictionary of procedure names to defn's
$stack = [];  # ooh, a stack, the last thing you'd expect here :-)

%vars  = ();  # dictionary of variables names to values

# For nice clean handling of lambda functions, we'll probably want
# to merge $proc and %vars into a single dictionary

### LINEAR SCANNER ###

# exact syntax for comments &amp; strings needs to be determined

sub token
{
  my $t = '';

RestartScan:

  while ($line =~ /^\s*$/)  # Get next line if we used up the current line
  {
    $line = <STDIN>;
    return undef if not defined $line;
    chomp $line;
    $line =~ s/^\s*//;
  }

# Remove any whitespace before the next token

  $line =~ s/^\s*//;

# Assuming strings look like "this", and comments look like (* this *).

  if ($line =~ /^\(\*(.*?)\*\)/)
  {
    $line = $';
    goto RestartScan;

 } elsif ($line =~ /^#!(.*?)$/) {	#to recognize hashbang lines --
					# you won't find this documented
					# in the spec so don't depend on it
	$line = $';
    goto RestartScan;
 } elsif ($line =~ /^\/\/(.*?)$/) {	#To avoid import symbols
	$line = $';
    goto RestartScan;
  } elsif ($line =~ /^(\".*?\")/)
  {
    $t = $1;
    $line = $';
    return $t;
  } elsif ($line =~ /^(\S+)/)
  {
    $t = $1;
    $line = $';
    return $t;
  } else
  {
    $line = '';
    goto RestartScan;
  }
}

### RECURSIVE DESCENT PARSER ###

#defn has been modified to generate an array of tokens and push a
# reference on the stack to be bound to a name later.

# defn has been modified to handle nested definitions using recursion.
# defn itself does not touch the stack, as that would mean nested
# definitions would actually be 'spit out' onto the top level,
# which, unless it's what you want, probably isn't what you want
# (cf. Shelta.)

# defn now only returns a reference to the array that comprises the
# definition.  It's up to the caller (elem) to push that ref onto
# the stack.

sub defn
{
  my @temp = ();
  if ($token eq '{')
  {
    push @temp, 'code';
    $token = token();
    while($token ne '}')
    {
      if ($token eq '{')
      {
        push @temp, defn();
      }
      elsif ($token eq '(')
      {
	push @temp, mklist();
      }
#
# (Jeff) I *think* this else belongs here. It wasn't in the
# original code, so the push/token() was always executed next.
# I thought that might cause code that has  the sequence } { to
# be interpreted wrong, because the { would get pushed, rather
# than begin a new recursion. So I put an else around it. If this
# is wrong, please take it out of mklist() as well.
#
      else
      {
	push @temp, $token;
	$token = token();
      }
    }
    $token = token();
    return [@temp];
  } else
  {
    warn "Internal error: defn() should only be called at the start of
a definition";
  }
}

#
# (Jeff)
#
# A coroutine for lists. Lists can be in code blocks, and
# vice versa. NB: calculated gotos get interesting here.
# you could argue that dup/pop/shatter is the only control
# structure you might need. Ick.
#
# In both routines, I added an "else" in the last stage,
# since I *think* not having it might be an error when two
# lists or code blocks butt up against one another...
#
# { "I am here" disp } { "here too" disp } seemed to
# push the second "{" instead of seeing it as the
# beginning of the next segment
#
# mklist and defn could/should be implemented as a
# single routine that takes '}' or ')' as an argument
# (what the termination character is) but I didn't want
# to intrude too much on working code, so I left it like
# this for now.
#

sub mklist
{
  my @temp = ();
  if ($token eq '(')
  {
    push @temp, 'list';
    $token = token();
    while($token ne ')')
    {
      if ($token eq '(')
      {
        push @temp, mklist();
      }
      elsif ($token eq '{')
      {
	push @temp, defn();
      }
      else
      {
	push @temp, $token;
	$token = token();
      }
    }
    $token = token();
    return [@temp];
  } else
  {
    warn "Internal error: defn() should only be called at the start of
a definition";
  }
}

sub elem
{
  if ($token eq '{')
  {
    push @{$stack}, defn();
  } elsif ($token eq '(')
  {
    push @{$stack}, mklist();
  } elsif ($token eq 'quit')  # this should maybe be handled by 'execute'
  {
    die "all done.\n";
  } else
  {
    execute($token);
    $token = token();
  }
}

sub parse
{
 	while(defined $token) {
    		elem();
  	}
}

### INTERPRETER ###

# Executing a proc object...

#
# (Jeff)
#
# I sucked some of the warnings up into this code block
# and adjusted it to skip over the "code" element in the
# list. This seemed more efficient than leaving this code
# in the ifyes/ifno/while execution below, especially if
# more control structures get added.
#
sub execblock {
	my $block = shift;
	my $i;
        if (ref($block) ne 'ARRAY')  # better safe than sorry
        {
        	warn "Can't execute a non-ARRAY reference as a routine";
        }
	elsif ($block->[0] ne 'code')
	{
		warn "Can't execute a non-code ARRAY";
	}
	else
	{
		for ($i = 1; $i <= $#{$block}; $i++)
		{
			execute($block->[$i]); # recursively exec procedure
		}
    	}
}

# composing a string

sub strcompose() {
	$s2 = pop @{$stack};
	$s1 = pop @{$stack};

	if ($s1 eq 'mk' || $s1 eq undef) {
		push @{$stack}, $s2;
	} else {
		push @{$stack}, $s1 . $s2;
		strcompose();
	}
}

# dump the stack
sub disparray {
	my $array = shift;
	my $i;

	if ($array->[0] eq 'list')
	{
		print '(';
	}
	elsif ($array->[0] eq 'code')
	{
		print '{';
	}
	else
	{
		warn 'Unknown array type';
	}

	for ($i = 1; $i <= $#{$array}; $i++)
	{
		print ' ';
		if (ref($array->[$i]) eq 'ARRAY')
		{
			disparray ($array->[$i]);
		}
		else
		{
			print $array->[$i];
		}
	}

	if ($array->[0] eq 'list')
	{
		print ' )';
	}
	else
	{
		print ' }';
	}
}

# This is where most of the interesting stuff happens.

sub execute {
	my $temp;

  	my $cmd = shift;

# Just print it
# (Jeff) This does not work for:
#		( 1 2 3 ) disp
# since disp doesn't know about lists. Should it? Disp doesn't
# know about code either. Perhaps this and dump should both
# use the same routine for printing.

 	if($cmd eq 'disp' || $cmd eq "cha'") {
    		if (ref($stack->[$i]) eq 'ARRAY')
			{
				disparray (pop @{$stack});
			}
			else
			{
				print pop @{$stack};
			}
                print "\n";

# or bitch about it

	} elsif ($cmd eq 'complain') {
		print STDERR "Error: ", pop @{$stack}, "\n";

# but if you don't have it in the first place you have to get it
# from somewhere, yes?

	} elsif ($cmd eq 'listen' || $cmd eq "'Ij") {
		$in = <STDIN>;
		push @{$stack}, $in;

# This may seem redundant, but a careful reading of the code indicates
# that elem() is called only once a line.
#
# (Chris) What?  No... elem() is called once per program element.
# A program element is a definition or an instruction in the main prog.
#
# (Brian) I knew I shoulda taken that left turn at Albuquerque...
#
# This clause duplicates its
# function for higher-level proc declarations (like say an iftrue clause)
# so this will actually work. It's a somewhat cheezy way of dealing with
# a really annoying bug, but here you go.
#
# (Chris) This IS redundant, because it can be (should be (is now))
# handled by the 'defn' production.
#
#	} elsif ($cmd eq '{') {
#		defn();

# (Chris) Instead, we may well be asked to execute a reference to an
# array: that is, a definition embedded into another definition.  It
# should come to us in the form of an ARRAY ref.  It's basically a
# literal value, so we do with it what we'd do with any literal
# value: push it onto the stack.

	} elsif (ref($cmd) eq 'ARRAY') {
		push @{$stack}, $cmd;

# dump is a debugging procedure. I don't know if it will be in the final
# language description, but I find it very useful for analyzing stack
# dynamics.
#
# (Jeff) I expanded it partially here to dump the contents of
# code segments and lists. This could be cleaned up too, but
# I just needed something quick &amp; dirty.


	} elsif ($cmd eq 'dump' || $cmd eq 'Hotlh') {
		for ($i = 0; $i <= $#{$stack}; $i++)
		{
			if ($i > 0)
			{
				print ' ';
			}
			if (ref($stack->[$i]) eq 'ARRAY')
			{
				disparray ($stack->[$i]);
			}
			else
			{
				print $stack->[$i];
			}
		}
		print "\n";
# some basic stack operations

	} elsif ($cmd eq 'pop' || $cmd eq 'woD') {	#pop
		pop @{$stack};
	} elsif ($cmd eq 'dup' || $cmd eq 'latlh') {	#dup
#
# (Jeff) 'dup' duplicates lists by value, not by reference, so
#	( 1 2 3 ) dup split
# yields
#	( 1 2 3 ) ( 1 2 ) 3
# rather than
#	( 1 2 ) ( 1 2 ) 3
#
		$temp = pop @{$stack};
		if (ref($temp) ne 'ARRAY')
		{
			push @{$stack}, $temp;
			push @{$stack}, $temp;
		}
		else
		{
		my $i;
		my $newarray = [ ];
			for ($i = 0; $i <= $#{$temp}; $i++)
			{
				push @{$newarray}, $temp->[$i];
			}
			push @{$stack}, $temp;
			push @{$stack}, $newarray;
		}
	} elsif ($cmd eq 'exch') {	#exch
		$temp = pop @{$stack};
		$tempb = pop @{$stack};
		push @{$stack}, $temp;
		push @{$stack}, $tempb;
	} elsif ($cmd eq 'clear') {
		$stack = [];
	} elsif ($cmd eq 'remember' || $cmd eq "qawHa'") {
		push @{$stack}, 'mk';

# This is a tough one -- the obvious implementation never bottoms out if
# there is no marker on the stack. Rather than going on a downward spiral, the
# interpreter simply looks for an empty stack and pretends that it found a
# marker.

 	} elsif ($cmd eq 'forget') {
		my $pval = '';

		while ($pval ne 'mk') {   # could also say:
                                #while (defined($pval) and $pval ne 'mk')
			$pval = pop @{$stack};
			if ($pval eq undef) {  # then just toss this
				$pval = 'mk';
			}
		}

# math operations

	} elsif ($cmd eq 'add') {
		$a = pop @{$stack};
		$b = pop @{$stack};
		push @{$stack}, $a + $b;
	} elsif ($cmd eq 'sub') {
		$b = pop @{$stack};
		$a = pop @{$stack};
		push @{$stack}, $a - $b;
	} elsif ($cmd eq 'mul') {
		$a = pop @{$stack};
		$b = pop @{$stack};
		push @{$stack}, $a * $b;
	} elsif ($cmd eq 'div') {
		$b = pop @{$stack};
		$a = pop @{$stack};
		push @{$stack}, $a/ $b; 	#best drop Larry a line about this;
					#$a/$b works, $a / $b doesn't. This
					# is clearly a bug.
                              # (Chris) I dunno, works on my Perl.
                              #This is Perl 5 right?

                                #This was a parsing oddity, and I don't know if
                                #it was peculiar to the version of Red Hat I was
                                #using at the time. Right now I am using 7.1.
        } elsif ($cmd eq 'mod') {
		$b = pop @{$stack};
		$a = pop @{$stack};
		push @{$stack}, $a % $b;
	} elsif ($cmd eq 'pow') {
		$b = pop @{$stack};
		$a = pop @{$stack};
		push @{$stack}, $a ** $b;

	} elsif ($cmd eq 'rand') {
		$rn = rand (pop @{$stack});
		push @{$stack}, $rn;
	} elsif ($cmd eq 'clip') {
		$a = pop @{$stack};
		push @{$stack}, int($a);
	} elsif ($cmd eq 'smooth') {
		$a = pop @{$stack};
		push @{$stack}, int($a + .5);
	} elsif ($cmd eq 'howmuch') {
		$a = pop @{$stack};
		push @{$stack}, abs($a);

# increment/decrement

	} elsif ($cmd eq 'sub1') {
		$a = pop@{$stack};
		push @{$stack}, $a - 1;
	} elsif ($cmd eq 'add1') {
		$a = pop@{$stack};
		push @{$stack}, $a + 1

# SIHpoj jangwI'mey

	} elsif ($cmd eq 'sin') {
		$a = pop @{$stack};
		push @{$stack}, sin($a);
	} elsif ($cmd eq 'cos') {
		$a = pop @{$stack};
		push @{$stack}, cos($a);
	} elsif ($cmd eq 'tan') {
		$a = pop @{$stack};
		push @{$stack}, tan($a);
	} elsif ($cmd eq 'atan') {	#equivalent to atan2() in C
		$d = pop @{$stack};
		$n = pop @{$stack};
		push @{$stack}, atan2($n,$d);

# ghurjangwI'mey

	} elsif ($cmd eq 'ln') {
		$a = pop @{$stack};
		push @{$stack}, log($a);

# (Jeff) list operations, more to come

	} elsif ($cmd eq 'split') {
		my $list = pop @{$stack};
		my $head = $list->[$#{$list}];
		pop @{$list};
		push @{$stack}, $list;
		push @{$stack}, $head;
	} elsif ($cmd eq 'cons') {
		my $a = pop @{$stack};
		my $list = pop @{$stack};
		push @{$list}, $a;
		push @{$stack}, $list;
	} elsif ($cmd eq 'shatter') {
		my $list = pop @{$stack};
		my $i;
		for ($i = 1; $i <= $#{$list}; $i++)
		{
			push @{$stack}, $list->[$i];
		}
	} elsif ($cmd eq 'empty') {
		my $list = $stack->[$#{$stack}];
		if (ref($list) ne 'ARRAY')
		{
			warn 'Cannot empty a non-array';
		}
		elsif ($#{$list} > 0)
		{
			push @{$stack}, 0;
		}
		else
		{
			push @{$stack}, 1;
		}

  #This function was one of Jeff's proposals that he didn't implement.
  # I can't seem to find either of my copies of the Klingon dictionary
  # to give it its "correct" name, though.

        } elsif ($cmd eq 'consume') {
		my $pval = '';
                my $temp;

                #note to the Perl newbie: Perl lists are really deques, at
                # least if you treat them like this. Shift/unshift essentially
                # push and pop from the wrong end; the implementation of
                # $temp here is essentially backwards from the system stack.

		while ($pval ne 'mk' and defined($pval)) {   # could also say:
                                #while (defined($pval) and $pval ne 'mk')
			$pval = pop @{$stack};
                        unless ($pval eq 'mk') {
                                unshift @{$temp}, $pval;
                        }
		}

                #read the freakin' source, Brian -- first pass through
                # I didn't notice that Jeff now has type checking on
                # arrays. Silly me. Anyway, this last bit just puts the
                # type icing on the array cake.

                unshift @{$temp}, 'list';

                push @{$stack}, $temp;

# numerical constants

	} elsif ($cmd eq 'pi') {
		push @{$stack}, 3.141592654;
	} elsif ($cmd eq 'e') {
		push @{$stack}, 2.718281824;

# data tests
# provided by j proctor <<a href="/ym/Compose?To=jproctor@oit.umass.edu&YY=3721&order=down&sort=date&pos=4">jproctor@oit.umass.edu</a>>

        } elsif ($cmd eq 'number?') {
                $a = pop @{$stack};
                if ($a =~ /^-?\d+\.?\d*$/) {  # lifted from Cookbook p.44
                        push @{$stack}, 1;
                } else {
                        push @{$stack}, 0;
                }
        } elsif ($cmd eq 'int?') {
                $a = pop @{$stack};
                if ($a =~ /^-?\d+$/) {        # lifted from Cookbookp.44
                        push @{$stack}, 1;
                } else {
                        push @{$stack}, 0;
                }
        } elsif ($cmd eq 'negative?') {
                $a = pop @{$stack};
                if ($a < 0) {
                        push @{$stack}, 1;
                } else {
                        push @{$stack}, 0;
                }
        } elsif ($cmd eq 'null?') {
                $a = pop @{$stack};
                if ($a eq "") {
                        push @{$stack}, 1;
                } else {
                        push @{$stack}, 0;
                }

# relational operators
#
# Note that the English keywords honor the ? convention. This is to
# maintain consistency with the use of -'a' in Klingon.

	} elsif ($cmd eq 'gt?') {
		$b = pop @{$stack};
		$a = pop @{$stack};
		if ($a > $b) {
			push @{$stack}, 1;
		} else {
			push @{$stack}, 0;
		}
	} elsif ($cmd eq 'ge?') {
		$b = pop @{$stack};
		$a = pop @{$stack};
		if ($a >= $b) {
			push @{$stack}, 1;
		} else {
			push @{$stack}, 0;
		}
	} elsif ($cmd eq 'lt?') {
		$b = pop @{$stack};
		$a = pop @{$stack};
		if ($a < $b) {
			push @{$stack}, 1;
		} else {
			push @{$stack}, 0;
		}
	} elsif ($cmd eq 'le?') {
		$b = pop @{$stack};
		$a = pop @{$stack};
		if ($a <= $b) {
			push @{$stack}, 1;
		} else {
			push @{$stack}, 0;
		}
	} elsif ($cmd eq 'eq?') {
		$b = pop @{$stack};
		$a = pop @{$stack};
		if ($a == $b) {
			push @{$stack}, 1;
		} else {
			push @{$stack}, 0;
		}
	} elsif ($cmd eq 'ne?') {
		$b = pop @{$stack};
		$a = pop @{$stack};
		if ($a != $b) {
			push @{$stack}, 1;
		} else {
			push @{$stack}, 0;
		}

# logical operators

	} elsif ($cmd eq 'and') {
		$a = pop @{$stack};
		$b = pop @{$stack};
		if ($a != 0 && $b != 0) {
			push @{$stack}, 1;
		} else {
			push @{$stack}, 1;
		}
	} elsif ($cmd eq 'or') {
		$a = pop @{$stack};
		$b = pop @{$stack};
		if ($a != 0 || $b != 0) {
			push @{$stack}, 1;
		} else {
			push @{$stack}, 1;
		}
	} elsif ($cmd eq 'xor') {
		$a = pop @{$stack};
		$b = pop @{$stack};
		if (($a != 0) xor ($b != 0)) {
			push @{$stack}, 1;
		} else {
			push @{$stack}, 1;
		}

# tlheghjangwI'

	} elsif ($cmd eq 'strmeasure') {
		$str = pop @{$stack};
		push @{$stack}, length($str);

	} elsif ($cmd eq 'strcut') {
		$end = pop @{$stack};
		$begin = pop @{$stack};
		$str = pop @{$stack};
		$end = $end - $begin;	#make the implementation conform
					# to the spec instead of the Perl
					# interpreter
		push @{$stack}, substr ($str, $begin, $end);

	} elsif ($cmd eq 'strtie') {
		$s2 = pop @{$stack};
		$s1 = pop @{$stack};
		push @{$stack}, $s1 . $s2;

	} elsif ($cmd eq 'streq?') {
		$s2 = pop @{$stack};
		$s1 = pop @{$stack};
		if ($s1 eq $s2) {
			push @{$stack}, 1;
		} else {
			push @{$stack}, 0;
		}
	} elsif ($cmd eq 'compose') {
		strcompose();

# You can't have a functional language without a conditional clause
#
# (Chris) Don't tempt me!!! :-)
#
# or you'll
# recurse forever and ever AND WE WOULDN'T WANT THAT, NOW, WOULD WE? For
# your convenience, var'aq provides two such constructs.

	} elsif ($cmd eq 'ifyes') {
		my $block = pop @{$stack};
		$cval = pop @{$stack};

		if ($cval != 0) {
			execblock($block);
		}

	} elsif ($cmd eq 'ifno') {
		my $block = pop @{$stack};
		$cval = pop @{$stack};

		if ($cval == 0) {
			execblock($block);
		}
	} elsif ($cmd eq 'repeat') {
		$block = pop @{$stack};
		$cval = pop @{$stack};

		while ($cval > 0) {
			execblock($block);
			if ($escv = 1) {
				$cval = 1;
				$escv = 0;
			}
			$cval--;
		}
	} elsif ($cmd eq 'eval') {
		$block = pop @{$stack};
#
# (Jeff) XXX Is the $cval pop (below) supposed to be here? "chov" just does
# an execute, so I think this would damage the stack.
#
		$cval = pop @{$stack};

		execblock($block);

# This operator exists for the sole purpose of making it possible to string
# a pair of if clauses together. Sharp-eyed code readers will note that
# in this implementation it's simply syntactic sugar for dup/latlh; that in
# mind, a more proper implementation might actually typecheck to see if
# that's an actual boolean on the stack.

	} elsif ($cmd eq 'choose') {
		$temp = pop @{$stack};
		push @{$stack}, $temp;
		push @{$stack}, $temp;

# (j proctor) Perl makes escaping easy: if it encounters this in the middle of
# executing a proc, it'll jump immediately to the end of it.  If
# there's nothing next, well, it's done.
# (Brian) Note, however, that repeat/vangqa' won't necessarily notice; you have
# to give it a nudge.

        } elsif ($cmd eq 'escape') {
                last;
                $escv = 1;

# The quote operator (~) will push a bare identifier onto the stack. Note that
# it's a special form; it comes *before* its operand. Veddy unusual, no?
# This operator is read as lI'moH (make useful) in Klingon.

	} elsif ($cmd eq '~') {
		push @{$stack}, $token = token();  # assign to global

# The name instruction takes a proc def and a value off the stack and binds
# it to an entry in $proc.

	} elsif ($cmd eq 'name') {
		$proc->{ pop @{$stack} } = pop @{$stack};

# Set does the same thing for %vars, but the contents get to not be
# write-only.
# (Chris) Mightn't you want to merge these two someday?
# (Brian) Eventually, maybe. Depends on whether I ever figure out how to
# separate variable and proc namespaces. At this point, we won't -- it
# isn't really necessary, and the parsing logic does that for us anyway.

	} elsif ($cmd eq 'set') {
		$n = pop @{$stack};
		$v = pop @{$stack};
		$vars{$n} = $v;

# At this point, we come down to anything that isn't a keyword.

# First we look for string literals. This makes it possible to do very
# useful things like write "hello, world" programs.  Which you can now do.

  	} elsif($cmd =~ /^\"(.*?)\"$/) {
    		push @{$stack}, $1;

# It's not a string, so we assume it's a number. At this point only decimal
# notation is supported.

  	} elsif($cmd =~ /^-?\d+.?\d*$/) {
    		push @{$stack}, 0+$cmd;

# Technically, variables and functions aren't in the same namespace, but
# since this is how it's parsed, they are, but you don't really want to know.
# Just for the sake of argument, let's say they are and do the lookup.

# (Chris) with this, you could just say that variables 'mask' procedure
# definitions.  Again, probably simpler to just merge them into the single
# namespace they so obviously share.

	} elsif (exists $vars{$cmd}) {
		push @{$stack}, $vars{$cmd};

# If that doesn't work we look it up in $proc and execute it if it's there.
#
# (Jeff) Changed this to call execblock, BUT THIS MAY BE WRONG. Someone
# who knows better than me should have a look at this.
#
  	} elsif(exists $proc->{$cmd}) {
    		my $block = $proc->{$cmd};
		execblock($block);

# Otherwise we bitch, whine, and complain to the user.

  	} else {
    		warn "Undefined function '$cmd'";
	}
}

### MAIN ###

print "var'aq Reference Edition -- pre-Martoq 20010904\n";
print "(c)2000 Brian Connors, Chris Pressey, and Mark Shoulson\n\n";
$token = token();
parse();

### END ###

# To those who actually read the code:
#
# Brian sez:
#
# Thanks for taking the time. I have found and continue to find the creation
# of this language a major educational experience, and I believe in making
# my (or I should say our, since Chris didn't have a problem with this either)
# code public record for whatever reason. At this point I'd like to thank
# Chris, without whom a lot of this would have been possible but not work
# nearly as nicely, and Mark Shoulson from the Klingon Language Institute, who
# as I write has only recently come aboard as a linguistic consultant to the
# project and will be making the best of his contribution down the road  a
# ways. The code is free under the Mozilla Public License, yours to do with as
# you wish as long as you don't try to tell us that we didn't write it.
#
# Chris sez:
#
# I did an awful lot of random hacking at this and adding comments meant
# mainly for Brian, who will likely take them (and possibly) this out
# (feel free, I doubt much of my jabber is actually likely to help some
# interested outside observer understand what's going on in here.)
# Truth be told, I probably broke as much as I fixed; it depends on how
# Brian wants to handle some of the binding issues (at runtime or
# definetime?)
# (Brian) Chris, you're free to jabber as much as you want :-)
#
# (brian) Added shouts go out to j proctor and Jeff Evarts for their
# code contrbutions, Merrick J. Stemens for threatening to write a VB
# version of var'aq, and Glenn Gaslin for putting this silly little project
# in Entertainment Weekly in January 2001.