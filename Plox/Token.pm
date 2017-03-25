package Plox::Token;
use v5.20;
use feature 'signatures';

use Moo;
use namespace::clean;

use strictures 2;
no warnings 'experimental::signatures';

use MooX::Types::MooseLike::Base qw(Enum Str Int);

has type => (
    is       => 'ro',
    required => 1,
    isa      => Enum [
        qw(
          LEFT_PAREN RIGHT_PAREN LEFT_BRACE RIGHT_BRACE
          COMMA DOT MINUS PLUS SEMICOLON SLASH STAR

          BANG    BANG_EQUAL
          EQUAL   EQUAL_EQUAL
          GREATER GREATER_EQUAL
          LESS    LESS_EQUAL

          IDENTIFIER STRING NUMBER

          AND   CLASS  ELSE  FALSE FUN  FOR IF NIL OR
          PRINT RETURN SUPER THIS  TRUE VAR WHILE

          EOF
          )
    ]
);
has lexeme => ( is => 'ro', required => 1, isa => Str );
has literal => ( is => 'ro', required => 0 );
has line => ( is => 'ro', required => 1, isa => Int );

sub toString($self) {
    my $str = $self->line . $self->type . " " . $self->lexeme;
    $str .= defined $self->literal ? " " . $self->literal : '';
    return $str;
}
1;
