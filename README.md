# var'aq

This is a copy of the var'aq language developed by Brian Connors, Chris Pressey, and Mark Shoulson, which I downloaded from a geocities mirror and uploaded to GitHub.

Since then, I've made a few changes focused on testing and integration. So far, they are:

- Automated some tests with BATS.
- Dockerized.
- Automated builds and testing with GitHub Actions.

The project as it was is not according to its specification, but enough of it is implemented that the 99 bottles example runs with a minor spelling correction.

The easiest way to try var'aq is to use its Docker image, which I have uploaded to Docker Hub.

Try var'aq:

```bash
    docker run -it bjtucker/varaq
```

If there is any other development or use of the var'aq language, I would love to hear about it. Please open an issue!

I intend to continue adding my own contributions to the project as time permits as a form of fandom and a learning experience. I welcome anyone who wishes to join me.

Ben

[![Build Status](https://img.shields.io/github/workflow/status/bjtucker/varaq/Run%20tests?label=Tests&logo=github&style=flat-square)](https://github.com/bjtucker/varaq/actions/workflows/tests.yml)


## Original README

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
