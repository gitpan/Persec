package Persec;
use Carp;
use Modern::Perl;
# ABSTRACT: so jalous of haskell's Parsec ...
our $VERSION = 0.0;

use parent 'Exporter';
our @EXPORT = qw/
    nextChar nextString
    exhaust
    surroundedBy
    canWS
    unparsed forgive_unparsed slurp_unparsed
/;
sub exhaust (&) {
    my @r;
    my $code = shift;
    while ( my @v = $code->() ) { push @r,@v }
    @r
}

sub unparsed { substr $_,pos($_) }
sub forgive_unparsed { pos($_) = length $_ }
sub slurp_unparsed {
    my $r = unparsed;
    forgive_unparsed;
    $r
}

sub WS        { m{\G\s+}cg   }
sub canWS     { m{\G\s*}cg   }
sub tailingWS { m{\G\s*\z}cg }

sub nextChar {
    return unless (shift) eq substr $_, pos($_),1;
    pos($_)++;
    1;
}

sub nextString {
    my $l      = length ( my $v = shift );
    my $substr = substr $_, pos($_), $l;
    return 0 unless $v eq $substr;
    pos($_)+=$l;
    1;
}

sub surroundedBy {
    my ( $begin, $end, $rule ) = @_;
    my $pos = pos($_);
    unless (nextChar $begin) {
        return;
    }
    my @r = $rule->();
    if ( nextChar $end ) {
        return \@r;
    }
    my $rem = unparsed;
    confess "closing symbol '$end' (starting at $pos) never found ($rem)";
}

sub parse {
    local $_ = pop;
    pos($_)  = 0;
    my ( $class, $rule ) = @_;
    $rule ||= 'TOP';
    if ( my $r = $class->$rule ) { wantarray ? ($r    ,unparsed) : $r }
    else                         { wantarray ? (undef ,unparsed) : () }
}

1;
