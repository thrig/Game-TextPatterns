# -*- Perl -*-
#
# generate patterns of text
#
# Run perldoc(1) on this file for additional documentation.

package Game::TextPatterns;

use 5.14.0;
use warnings;
use Moo;
use namespace::clean;
use Scalar::Util qw(looks_like_number);

our $VERSION = '0.01';

with 'MooX::Rebuild';    # for ->rebuild (which differs from clone)

has pattern => (
    is     => 'rw',
    coerce => sub {
        my $type = ref $_[0];
        if ( $type eq "" ) { return [ split $/, $_[0] ] }
        elsif ( $type eq 'ARRAY' )      { return [ @{ $_[0] } ] }
        elsif ( $_[0]->can("pattern") ) { return [ @{ $_[0]->pattern } ] }
        else                            { die "unknown pattern type '$type'" }
    },
);

########################################################################
#
# METHODS

# TODO append by cols or by rows with handling of not-same-size cases somehow
sub append_cols {
    my ( $self, $pattern ) = @_;
    my $pat = $self->pattern;
    my $len = length $pat->[0];
    ...
    return $self;
}

sub append_rows {
    my ( $self, $new ) = @_;
    my $pat = $self->pattern;
    ...
    push @$pat, @{$new->pattern};
    return $self;
}

sub border {
    my ( $self, $width, $char ) = @_;
    if ( defined $width ) {
        die "width must be a positive integer"
          if !looks_like_number($width)
          or $width < 1;
        $width = int $width;
    } else {
        $width = 1;
    }
    if ( defined $char and length $char ) {
        $char = substr $char, 0, 1;
    } else {
        $char = '#';
    }
    my $pat = $self->pattern;
    my ( $cols, $rows ) = ( length $pat->[0], scalar @$pat );
    my ( $newcols, $newrows ) = map { $_ + ( $width << 1 ) } $cols, $rows;
    my @np = ( $char x $newcols ) x $width;
    for my $row (@$pat) {
        push @np, ( $char x $width ) . $row . ( $char x $width );
    }
    push @np, ( $char x $newcols ) x $width;
    $self->pattern( \@np );
    return $self;
}

sub clone { __PACKAGE__->new( pattern => $_[0]->pattern ) }

sub cols       { length $_[0]->pattern->[0] }
sub dimensions { length $_[0]->pattern->[0], scalar @{ $_[0]->pattern } }
sub rows       { scalar @{ $_[0]->pattern } }

# "mirrors are abominable" (Jorge L. Borges. "Tlön, Uqbar, Orbis Tertuis")
# so the term flip is here used instead
sub flip_both {
    my ($self) = @_;
    my $pat = $self->pattern;
    for my $row (@$pat) {
        $row = reverse $row;
    }
    @$pat = reverse @$pat if @$pat > 1;
    return $self;
}

sub flip_cols {
    my ($self) = @_;
    for my $row ( @{ $self->pattern } ) {
        $row = reverse $row;
    }
    return $self;
}

sub flip_rows {
    my ($self) = @_;
    my $pat = $self->pattern;
    @$pat = reverse @$pat if @$pat > 1;
    return $self;
}

sub multiply {
    my ( $self, $cols, $rows ) = @_;
    die "cols must be a positive integer"
      if !defined $cols
      or !looks_like_number($cols)
      or $cols < 1;
    $cols = int $cols;
    if ( defined $rows ) {
        die "rows must be a positive integer"
          if !looks_like_number($rows)
          or $rows < 1;
        $rows = int $rows;
    } else {
        $rows = $cols;
    }
    if ( $cols > 1 ) {
        for my $row ( @{ $self->pattern } ) {
            $row = $row x $cols;
        }
    }
    if ( $rows > 1 ) {
        $self->pattern( [ ( @{ $self->pattern } ) x $rows ] );
    }
    return $self;
}

# TODO rotate -- 90, 180, 270 -- is 180 same as flip_both?
# make direction the same as motion on unit circle so 90 is to the left?

sub string {
    my ( $self, $sep ) = @_;
    $sep //= $/;
    return join( $sep, @{ $self->pattern } ) . $sep;
}

1;

__END__
TODO pod
