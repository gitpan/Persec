#! /usr/bin/perl
package Math;
use Modern::Perl;
use Persec;
use parent 'Persec';
# use re qw< /xms >; # die! outdated linux distributions! die! 
use Carp;

sub block;
sub expr;
sub value       { m{\G \s* (\d+)    \s*}cgxms and return $1 }
sub operator    { m{\G \s* ([-+*/]) \s*}cgxms and return $1 }
sub block       {
    surroundedBy qw/ (  ) /
    , \&expr
}
sub composition { (operator or return)       , expr }
sub expr        { (block || value or return) , composition }
sub TOP         { [expr] }

package main;
use Modern::Perl;
use Test::More tests => 1;

is_deeply
(   [ Math->parse("(3 * (987 + 2 ) - 5 * 5) / 45") ]
,   [   [ [ qw/ 3 * /, [qw/ 987 + 2 /], qw/ - 5 * 5 / ]
        , qw{ / 45 } ] # the ast
    , '' # nothing unparsed
    ]
, "we did it")
