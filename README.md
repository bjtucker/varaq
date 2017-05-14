This is a copy of the var'aq language developed by Brian Connors, Chris 
Pressey, and Mark Shoulson, which I downloaded from a geocities mirror
and uploaded to github.

Since then I've made few changes, focused on testing and integration.
So far, they are:
  * automated tests with BATS
  * dockerized
  * automated builds and testing with Travis-ci.

The project as it was is not according to its specification, but enough
of it is implememted that the 99 bottles example runs with a minor
spelling correction.

The easiest way to try var'aq is using its docker image, which I have
uploaded to dockerhub.

Try var'aq

    docker run -it bjtucker/varaq

If there is any other development or use of the var'aq language, I would
love to hear about it. Please open an issue!

I intend to continue adding my own contributions to the project as time
permits as a form of fandom and a learning experience. I welcome anyone
who wishes to join me.

Ben

[![tv-image][]][tv-site]

[tv-image]: https://travis-ci.org/bjtucker/varaq.svg?branch=master
[tv-site]: https://travis-ci.org/bjtucker/varaq/branches

The original README is included below

----

This is var'aq, the first Klingon programming language. This is the
Azetbur ('aDSetbur?) release, dated 1/05/2001, named for the Klingon
chancellor Azetbur gorqon puqbe' in Star Trek VI: The Undiscovered
Country. 

It is to be considered an alpha release; for information on what
it's capable of, see the files current.html and gettingstarted.txt. 

var'aq was developed on a Linux system using Perl 5. If you are not currently
using a Unix-based system, you may want to rename the interpreter files
(varaq-engl and varaq-kling) with a .pl extension.

If this is your first exposure to var'aq, please read the FAQ
(varaqfaq.html) before you do anything else. You may also wish to
subscribe to our eGroups mailing list; the information is in the FAQ.

Thank you, enjoy, and Qapla'!

Brian Connors
Chris Pressey
Mark Shoulson
1/05/2001
