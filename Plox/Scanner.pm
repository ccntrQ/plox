package Plox::Scanner;
use v5.20;
use feature 'signatures';

use Moo;
use namespace::clean;

use strictures 2;
no warnings 'experimental::signatures';

use Plox;
use Plox::Token;

# XXX add types
has source => ( is => 'ro', required => 1 );
has tokens => ( is => 'rw', default => sub { [] } );

# we need these to track the position
has start   => ( is => 'rw', default => 0 );
has current => ( is => 'rw', default => 0 );
has line    => ( is => 'rw', default => 1 );

# reserved keywords hash
has keywords => (
    is      => 'ro',
    default => sub {
        {
            and    => 'AND',
            class  => 'CLASS',
            else   => 'ELSE',
            false  => 'FALSE',
            for    => 'FOR',
            fun    => 'FUN',
            if     => 'IF',
            nil    => 'NIL',
            or     => 'OR',
            print  => 'PRINT',
            return => 'RETURN',
            super  => 'SUPER',
            this   => 'THIS',
            true   => 'TRUE',
            var    => 'VAR',
            while  => 'WHILE',
        }

    }
);

sub scanTokens($self) {
    while ( !$self->isAtEnd ) {
        $self->start( $self->current );

        $self->scanToken;
    }

    push @{ $self->tokens }, Plox::Token->new(
        type    => 'EOF',
        lexeme  => '',
        literal => undef,
        line    => $self->line

    );

    return $self->tokens;
}

sub scanToken($self) {
    my $char = $self->advance;

    if ( $char eq '(' ) {
        $self->addToken('LEFT_PAREN');
    }
    elsif ( $char eq ')' ) {
        $self->addToken('RIGHT_PAREN');
    }
    elsif ( $char eq '{' ) {
        $self->addToken('LEFT_BRACE');
    }
    elsif ( $char eq '}' ) {
        $self->addToken('RIGHT_BRACE');
    }
    elsif ( $char eq ',' ) {
        $self->addToken('COMMA');
    }
    elsif ( $char eq '.' ) {
        $self->addToken('DOT');
    }
    elsif ( $char eq '-' ) {
        $self->addToken('MINUS');
    }
    elsif ( $char eq '+' ) {
        $self->addToken('PLUS');
    }
    elsif ( $char eq ';' ) {
        $self->addToken('SEMICOLON');
    }
    elsif ( $char eq '*' ) {
        $self->addToken('STAR');
    }
    elsif ( $char eq '!' ) {
        $self->addToken( $self->match('=') ? 'BANG_EQUAL' : 'BANG' );
    }
    elsif ( $char eq '=' ) {
        $self->addToken( $self->match('=') ? 'EQUAL_EQUAL' : 'EQUAL' );
    }
    elsif ( $char eq '<' ) {
        $self->addToken( $self->match('=') ? 'LESS_EQUAL' : 'LESS' );
    }
    elsif ( $char eq '>' ) {
        $self->addToken( $self->match('=') ? 'GREATER_EQUAL' : 'GREATER' );
    }
    elsif ( $char eq '/' ) {
        if ( $self->match('/') ) {    # we have a comment
            $self->advance while $self->peek ne "\n";
        }
        else {
            $self->addToken('SLASH');
        }
    }
    elsif ( $char eq '"' ) {
        $self->string;
    }
    elsif ( isDigit($char) ) {
        $self->number;
    }
    elsif ( isAlpha($char) ) {
        $self->identifier;
    }
    elsif ( isWhitespace($char) ) {
        return;
    }
    elsif ( $char eq "\n" ) {
        $self->line( $self->line + 1 );
    }
    else {
        Plox::error( $self->line, "Unexpected Character." );
    }
}

sub addToken ( $self, $type, $literal = undef ) {

    my $text = _substr( $self->source, $self->start, $self->current );
    push @{ $self->tokens },
      Plox::Token->new(
        type    => $type,
        lexeme  => $text,
        literal => $literal,
        line    => $self->line
      );
}

sub identifier($self) {
    $self->advance while isAlphaNumeric( $self->peek );

    my $text = _substr( $self->source, $self->start, $self->current );

    # check if either a reserved keyword or an identifier
    my $type = $self->keywords->{$text} // 'IDENTIFIER';
    $self->addToken($type);
}

sub number($self) {
    $self->advance while isDigit( $self->peek );

    if ( $self->peek eq '.' && isDigit( $self->peekNext ) ) {
        $self->advance while isDigit( $self->peek );
    }

    $self->addToken(
        'NUMBER',

        # number and string... it's all the same for us ;)
        _substr( $self->source, $self->start, $self->current )
    );
}

sub string($self) {
    while ( $self->peek ne '"' && !$self->isAtEnd ) {
        $self->advance;
    }

    if ( $self->isAtEnd ) {
        Plox::error( $self->line, "Unterminated String." );
        return;
    }

    $self->advance;    # get the terminating "

    $self->addToken( 'STRING',
        _substr( $self->source, $self->start + 1, $self->current - 1 ) );
}

sub advance($self) {

    # XXX there must be a prettier way to do this. i use this all over the
    #     place and it is really ugly
    $self->current( $self->current + 1 );
    return substr( $self->source, $self->current - 1, 1 );
}

sub match ( $self, $expected ) {
    return 0 if $self->isAtEnd || $self->charAtCurrent ne $expected;
    $self->current( $self->current + 1 );
    return 1;
}

sub peek ($self) {
    return '' if $self->isAtEnd;
    return $self->charAtCurrent;
}

# maximum lookahead of 2
sub peekNext($self) {
    return '' if $self->current + 1 >= length( $self->source );
    return substr( $self->source, $self->current + 1, 1 );
}

sub charAtCurrent($self) {
    return substr( $self->source, $self->current, 1 );
}

sub isAtEnd($self) {
    return $self->current >= length( $self->source );
}

# helper
sub isDigit($char) {
    $char =~ m/\d/;
}

sub isAlpha($char) {
    $char =~ m/[a-z_]/i;
}

sub isAlphaNumeric($char) {
    isDigit($char) || isAlpha($char);
}

sub isWhitespace($char) {
    $char =~ m/ /;
}

sub _substr ( $str, $start, $end ) {
    my $offset = $end - $start;
    die 'end before start!' if $offset < 0;

    return substr( $str, $start, $offset );
}

1;
