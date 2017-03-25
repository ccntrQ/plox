package Plox;
use v5.20;
use feature 'signatures';

use Moo;
use namespace::clean;

use strictures 2;
no warnings 'experimental::signatures';

use Plox::Scanner;
use Plox::Parser;
use Plox::AstPrinter;

sub main($self) {

    if ( defined $ARGV[0] ) {
        $self->runFile( $ARGV[0] );
    }
    else {
        $self->runPrompt();
    }

    exit 0;
}

sub run ( $self, $source ) {
    my $scanner = Plox::Scanner->new( source => $source );
    my $tokens = $scanner->scanTokens;

    my $parser = Plox::Parser->new( tokens => $tokens );
    my $expression = $parser->parse;

    say Plox::AstPrinter->new->pprint($expression) if !hadError();
}

sub runPrompt($self) {
    while (1) {
        print "> ";
        chomp( my $line = <STDIN> );
        $self->run($line);
        hadError(0);
    }
}

sub runFile ( $self, $filepath ) {

    my $source;

    local $/ = undef;    # slurp...
    open( my $fh, '<', $filepath ) or die "couldn't read source file: $!";
    $source = <$fh>;
    close $fh;

    $self->run($source);

    exit(65) if hadError();
}

sub error ( $line, $msg ) {
    report( $line, "", $msg );
}

sub perror ( $token, $msg ) {
    if ( $token->type eq 'EOF' ) {
        report( $token->line, ' at end', $msg );
    }
    else {
        report( $token->line, " at '" . $token->lexeme . "'", $msg );
    }
}

sub report ( $line, $where, $msg ) {
    say STDERR "[line $line] Error$where: $msg";
    hadError(1);
}

sub hadError( $setErr = undef ) {

    # the java implementation uses a static attrib for this.
    # a package variable would resemble this closer probably
    state $err = 0;
    $err = $setErr if defined $setErr;
    return $err;
}

1;
