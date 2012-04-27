#! /usr/bin/perl

package testA;
use Persec;
use parent 'Persec';

sub TOP {
    return unless nextString "toto";
    return { pos => pos($_) }
}

package testB;
use Persec;
use parent 'Persec';
# use re '/xms'; perl 5.14 only

sub TOP {
    m{ \G \w+ \s+ }cgxms or return 0;
    nextString "YEAH" and return pos($_);
    0;
}

package main;
use Modern::Perl;
use autodie;
use YAML ();
use Test::More tests => 4;

my $got; 


$got = (testA->parse("toto"))[0]; 
is_deeply
( $got
, {qw/ pos 4 /}
, "testA parse"
);

$got = (testA->parse("tutu"))[0]; 
is_deeply
( $got
, undef
, "testA reject"
);

$got = (testB->parse("tutu YEAH"))[0]; 
ok( $got, "testB parse");


$got = (testB->parse("tutu oops"))[0]; 
ok( !$got, "testB reject" );
