#!/usr/bin/env perl
use v5.20;
use feature 'signatures';
use strictures 2;
no warnings 'experimental::signatures';

use Plox::AstPrinter;
use Plox::Expr::Binary;
use Plox::Expr::Unary;
use Plox::Expr::Literal;
use Plox::Expr::Grouping;
use Plox::Token;

my $demoexpr = Plox::Expr::Binary->new(
    left => Plox::Expr::Unary->new(
        operator =>
          Plox::Token->new( type => 'MINUS', lexeme => '-', line => 1 ),
        right => Plox::Expr::Literal->new( value => '123' )
    ),
    operator => Plox::Token->new( type => 'PLUS', lexeme => '+', line => 1 ),
    right    => Plox::Expr::Grouping->new(
        expression => Plox::Expr::Literal->new( value => '44.54' )
    )
);

say Plox::AstPrinter->new->pprint($demoexpr);
