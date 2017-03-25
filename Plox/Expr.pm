package Plox::Expr;
use v5.20;
use feature 'signatures';
use Moo;
use namespace::clean;
use strictures 2;
no warnings 'experimental::signatures';

sub accept($self, $visitor){...}
package Plox::Visitor;
use v5.20;
use feature 'signatures';
use Moo::Role;
use namespace::clean;
use strictures 2;
no warnings 'experimental::signatures';

requires qw(visitBinaryExpr visitGroupingExpr visitLiteralExpr visitUnaryExpr);
package Plox::Expr::Binary;
use v5.20;
use feature 'signatures';
use Moo;
use namespace::clean;
use strictures 2;
no warnings 'experimental::signatures';

use MooX::Types::MooseLike::Base qw(InstanceOf);
use base 'Plox::Expr';

has left => (is => 'ro',  isa => InstanceOf['Plox::Expr'], required => 1 );
has operator => (is => 'ro',  isa => InstanceOf['Plox::Token'], required => 1 );
has right => (is => 'ro',  isa => InstanceOf['Plox::Expr'], required => 1 );
sub accept($self, $visitor){ $visitor->visitBinaryExpr($self)}

package Plox::Expr::Grouping;
use v5.20;
use feature 'signatures';
use Moo;
use namespace::clean;
use strictures 2;
no warnings 'experimental::signatures';

use MooX::Types::MooseLike::Base qw(InstanceOf);
use base 'Plox::Expr';

has expression => (is => 'ro',  isa => InstanceOf['Plox::Expr'], required => 1 );
sub accept($self, $visitor){ $visitor->visitGroupingExpr($self)}

package Plox::Expr::Literal;
use v5.20;
use feature 'signatures';
use Moo;
use namespace::clean;
use strictures 2;
no warnings 'experimental::signatures';

use MooX::Types::MooseLike::Base qw(InstanceOf);
use base 'Plox::Expr';

has value => (is => 'ro',  required => 1 );
sub accept($self, $visitor){ $visitor->visitLiteralExpr($self)}

package Plox::Expr::Unary;
use v5.20;
use feature 'signatures';
use Moo;
use namespace::clean;
use strictures 2;
no warnings 'experimental::signatures';

use MooX::Types::MooseLike::Base qw(InstanceOf);
use base 'Plox::Expr';

has operator => (is => 'ro',  isa => InstanceOf['Plox::Token'], required => 1 );
has right => (is => 'ro',  isa => InstanceOf['Plox::Expr'], required => 1 );
sub accept($self, $visitor){ $visitor->visitUnaryExpr($self)}

1;
