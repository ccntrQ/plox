package GenerateAst;
use v5.20;
use feature 'signatures';

# TODO:
# - I wanted to look into Moo/Moose Metaprogramming for a long time. This seems
#   like a good opportunity. This is really messy anyways.

use Moo;
use namespace::clean;

use strictures 2;
no warnings 'experimental::signatures';

sub main($self) {

    my $outputDir = $ARGV[0] // die "Usage: $! <output_dir>\n";

    defineAst(
        $outputDir,
        "Expr",
        [
            "Binary   : Expr left, Token operator, Expr right",
            "Grouping : Expr expression",
            "Literal  : value",
            "Unary    : Token operator, Expr right",
        ]
    );
}

sub boilerplate {
    <<EOF;
use v5.20;
use feature 'signatures';
use Moo;
use namespace::clean;
use strictures 2;
no warnings 'experimental::signatures';
EOF
}

sub defineAst ( $outputDir, $baseName, $types ) {

    my $outFile = "$outputDir/$baseName.pm";

    my $fh = _open($outFile);
    say $fh "package Plox::$baseName;";
    say $fh boilerplate();
    say $fh "sub accept(" . '$self, $visitor){...}';

    defineVisitor( $fh, $baseName, $types );

    for my $type (@$types) {
        my ( $className, $fields ) = split( ':', $type );
        $className =~ s/\s//g;
        defineType( $fh, $baseName, $className, $fields );
    }

    say $fh "1;";
}

sub defineType ( $fh, $baseName, $className, $fields ) {
    say $fh "package Plox::$baseName" . "::$className;";
    say $fh boilerplate;
    say $fh "use MooX::Types::MooseLike::Base qw(InstanceOf);"
      ;    # not necessary for Literal
    say $fh "use base 'Plox::$baseName';";
    say $fh "";

    my @fields = split( ',', $fields );

    for my $field (@fields) {
        my ( $name, $type ) = reverse split( ' ', $field );

        defineField( $fh, $baseName, $name, $type );
    }

    say $fh "sub accept("
      . '$self, $visitor){ $visitor->visit'
      . "$className$baseName"
      . '($self)}';

    say $fh "";
}

sub defineVisitor ( $fh, $baseName, $types ) {

    say $fh "package Plox::Visitor;";
    say $fh <<EOF;
use v5.20;
use feature 'signatures';
use Moo::Role;
use namespace::clean;
use strictures 2;
no warnings 'experimental::signatures';
EOF
    my @requiredMethods;
    for my $type (@$types) {
        my ($className) = split( ':', $type );
        $className =~ s/\s//g;

        push @requiredMethods, "visit$className$baseName";

    }

    say $fh "requires qw(@requiredMethods);";
}

sub defineField ( $fh, $baseName, $name, $type = undef ) {
    my $isa = '';
    $isa = " isa => InstanceOf['Plox::$type'],"
      if defined $type;
    say $fh "has $name => (is => 'ro', $isa required => 1 );";
}

sub _open {
    my ($outFile) = @_;
    open( my $fh, '>', $outFile ) or die "can't open file: $!";

    return $fh;
}

1;
