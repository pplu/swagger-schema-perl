package Swagger::Schema::WithRefSupport;
use Moose;
extends 'Swagger::Schema';

use Safe::Isa;
use Scalar::Util qw/ weaken /;

around new => sub {
  my ( $orig, $class, $data ) = @_;

  my %refs;

  my $scan_for_references;
  $scan_for_references = sub {
    my ( $this, $path ) = @_;
    for my $field ( sort keys %$this ) {
      my $val = $this->{ $field };
      next unless ref $val eq 'HASH';
      if ( keys %$val == 1 and exists $val->{'$ref'} ) {
        $refs{ join( q{|}, @$path, $field ) } = $val->{'$ref'};
        # printf STDERR "Ref in %s:\n  %s\n", join( q{|}, @$path, $field ), $val->{'$ref'};

        my $path = $val->{'$ref'};
        if ( $path !~ m{^#/} ) { warn "External/relative refs ($path) not supported\n"; return }

        my @comps = split q{/}, $path =~ s{^#/}{}r;

        my $ref = $data;
        $ref = eval{ $ref->{ $_ }} for @comps;

        if ( not $ref ) { warn "Undefined reference ($path) found\n"; return $_ }

      } else {
        $scan_for_references->( $val, [ @$path, $field ]);
      }
    }
  };

  $scan_for_references->( $data, []);

  my $schema = $class->$orig( $data );

  while ( my ( $field, $ref ) = each %refs ) {
    # printf STDERR "Expanding %s\n", $field;

    my $reason = 'unknown reason';

    my $this = $schema;
    my @comps = split q{\|}, $field;
    $this = eval{
      $reason = "`$_` doesn't exist"
        if $this and not $this->$_can( $_ ) || exists $this->{ $_ };

      $this->$_can( $_ ) ? $this->$_ : $this->{ $_ };
    } for @comps[ 0 .. ( $#comps - 1 )];

    if ( not $this or not exists $this->{ $comps[-1]} ) {
      warn "Can't reconstruct schema location at `${field}`: $reason\n";
      next;
    }

    my $other = $schema;
    my @path = split q{/}, $ref =~ s{^#/}{}r;
    $other = eval{
      $reason = "Field $_ not found"
        if $other and not $other->$_can( $_ ) || exists $other->{ $_ };

      $other->$_can( $_ ) ? $other->$_ : $other->{ $_ }
    } for @path;

    if ( not $other ) {
      warn "Can't resolve reference `$ref`: $reason\n";
      next;
    }

    weaken $other;
    $this->{ $comps[-1] } = $other;
  }

  return $schema;

};

__PACKAGE__->meta->make_immutable( inline_constructor => 0 );

1;

### main pod documentation begin ###

=encoding UTF-8

=head1 NAME

Swagger::Schema::WithRefSupport - EXPERIMENTAL $ref support for Swagger::Schema

=head1 SYNOPSIS

  use File::Slurp;
  my $data = read_file($swagger_file);
  my $schema = Swagger::Schema::WithRefSupport->MooseX::DataModel::new_from_json($data);

=head1 DESCRIPTION

Experimental, extremely hack-ish reference resolution for L<Swagger::Schema>

=head1 COPYRIGHT and LICENSE

Copyright (c) 2019 by Sebastian Willert

This code is distributed under the Apache 2 License. The full text of the
license can be found in the LICENSE file included with this module.
