package Plox::Parser;
use v5.20;
use feature 'signatures';

use Moo;
use namespace::clean;

use strictures 2;
no warnings 'experimental::signatures';

use Plox;
use Plox::ParseError;
use Plox::Token;
use Plox::Expr;    # all Expr in here

use Try::Tiny;
use Scalar::Util qw(blessed);

# XXX add types
has tokens  => ( is => 'ro', required => 1 );
has current => ( is => 'rw', default  => 0 );

sub parse($self) {
    my $res;
    try {
        $res = $self->expression;
    }
    catch {
        die $_ if !blessed $_ || !$_->isa('Plox::ParseError');
    };

    return $res;
}

### parser rules

# this will change later. for now it's a stupid wrapper
sub expression($self) { $self->equality }

sub equality ($self) {
    my $expr = $self->comparison;

    while ( $self->match( 'BANG_EQUAL', 'EQUAL_EQUAL' ) ) {
        my $operator = $self->previous;
        my $right    = $self->comparison;
        $expr = Plox::Expr::Binary->new(
            left     => $expr,
            operator => $operator,
            right    => $right
        );

    }

    return $expr;
}

sub comparison($self) {
    my $expr = $self->term;

    while ( $self->match(qw(GREATER GREATER_EQUAL LESS LESS_EQUAL)) ) {
        my $operator = $self->previous;
        my $right    = $self->term;
        $expr = Plox::Expr::Binary->new(
            left     => $expr,
            operator => $operator,
            right    => $right
        );
    }

    return $expr;
}

sub term ($self) {
    my $expr = $self->factor;

    while ( $self->match(qw(MINUS PLUS)) ) {
        my $operator = $self->previous;
        my $right    = $self->factor;
        $expr = Plox::Expr::Binary->new(
            left     => $expr,
            operator => $operator,
            right    => $right
        );
    }

    return $expr;

}

sub factor ($self) {

    my $expr = $self->unary;
    while ( $self->match(qw(SLASH STAR )) ) {
        my $operator = $self->previous;
        my $right    = $self->unary;
        $expr = Plox::Expr::Binary->new(
            left     => $expr,
            operator => $operator,
            right    => $right
        );
    }

    return $expr;
}

sub unary ($self) {
    if ( $self->match(qw(BANG MINUS)) ) {
        my $operator = $self->previous;
        my $right    = $self->unary;

    }
    return $self->primary;
}

sub primary ($self) {
    return Plox::Expr::Literal( value => 0 )     if $self->match('FALSE');
    return Plox::Expr::Literal( value => 1 )     if $self->match('TRUE');
    return Plox::Expr::Literal( value => undef ) if $self->match('NIL');

    if ( $self->match(qw(NUMBER STRING)) ) {
        return Plox::Expr::Literal->new( value => $self->previous->literal );
    }

    if ( $self->match('LEFT_PAREN') ) {
        my $expr = $self->expression;
        $self->consume( 'RIGHT_PAREN', "Expect ')' after expression." );
        return Plox::Expr::Grouping->new( expression => $expr );
    }

    die $self->error( $self->peek, 'Expect expression.' );
}

### parsing primitives

sub match ( $self, @tokenTypes ) {
    for my $type (@tokenTypes) {
        if ( $self->check($type) ) {
            $self->advance;
            return 1;
        }
    }
    return 0;
}

sub consume ( $self, $tokenType, $errMsg ) {
    return $self->advance if $self->check($tokenType);

    die $self->error( $self->peek, $errMsg );
}

sub check ( $self, $tokenType ) {
    return 0 if $self->isAtEnd;

    return $self->peek->type eq $tokenType;
}

sub advance( $self) {
    $self->current( $self->current + 1 ) if !$self->isAtEnd;
    return $self->previous;
}

sub isAtEnd( $self) { $self->peek eq 'EOF' }

sub peek( $self) { $self->tokens->[ $self->current ] }

sub previous( $self) { $self->tokens->[ $self->current - 1 ] }

sub error ( $self, $token, $errMsg ) {
    Plox::perror( $token, $errMsg );
    return Plox::ParseError->new;
}

sub synchronize($self) {
    $self->advance;

    while ( !isAtEnd() ) {
        return if ( $self->previous->type eq 'SEMICOLON' );

        return
          if grep { $self->peek->type eq $_ }
          qw( CLASS FUN VAR FOR IF WHILE PRINT RETURN );

        $self->advance;
    }
}

1;
