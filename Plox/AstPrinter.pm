package Plox::AstPrinter;
use v5.20;
use feature 'signatures';

use Moo;
use namespace::clean;

use strictures 2;
no warnings 'experimental::signatures';

use Plox::Expr; # contains the visitor role

with('Plox::Visitor');

# i called this p(retty)print to avoind confusion with perls builtin print
sub pprint ( $self, $expr ) {
    return $expr->accept($self);
}

# @Overrides
sub visitBinaryExpr ( $self, $binaryExpr ) {
    return $self->parenthesize( $binaryExpr->operator->lexeme,
        $binaryExpr->left, $binaryExpr->right );
}

# @Overrides
sub visitGroupingExpr ( $self, $groupingExpr ) {
    return $self->parenthesize( 'group', $groupingExpr->expression );
}

# @Overrides
sub visitLiteralExpr ( $self, $literalExpr ) {
    return $literalExpr->value;    # just return the value. it's all strings...
}

# @Overrides
sub visitUnaryExpr ( $self, $unaryExpr ) {
    return $self->parenthesize( $unaryExpr->operator->lexeme, $unaryExpr->right );
}

sub parenthesize ( $self, $name, @expressions ) {
    my $out = "($name";

    for my $expr (@expressions) {
        $out .= " ";
        $out .= $expr->accept($self);
    }
    $out .= ")";

    return $out;
}
1;
