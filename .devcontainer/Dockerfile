FROM mcr.microsoft.com/vscode/devcontainers/base:debian-12

RUN apt-get update && apt-get install -y \
  libanyevent-perl \
  libclass-refresh-perl \
  libcompiler-lexer-perl \
  libdata-dump-perl \
  libio-aio-perl \
  libjson-perl \
  libmoose-perl \
  libpadwalker-perl \
  libscalar-list-utils-perl \
  libcoro-perl

ARG PERL_MM_USE_DEFAULT=1
RUN cpan Perl::LanguageServer
