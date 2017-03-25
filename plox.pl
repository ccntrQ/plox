#!/usr/bin/env perl
use v5.20;
use strictures 2;
use lib 'lib/local/lib/perl5/'; # carton dependencies

use Plox;
Plox->new->main();
